@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Miramee GitHub Pages Setup
echo ========================================================
echo   Starting Miramee GitHub Pages setup...
echo ========================================================
echo.
chcp 65001 >nul
set "LOG_FILE=%~dp0miramee-publish.log"
echo Started: %date% %time%>"%LOG_FILE%"

rem ===== 変更するのはここだけ =====
set "REPO_NAME=miramee-site"
set "COMMIT_MESSAGE=Publish Miramee website"
rem ================================

cd /d "%~dp0"
echo.
echo [1/6] 必要なツールを確認しています...
echo [1/6] Checking required tools...>>"%LOG_FILE%"

where winget >nul 2>&1
if errorlevel 1 (
  echo.
  echo winget が見つかりません。
  echo Microsoft Storeで「アプリ インストーラー」を更新してから、もう一度実行してください。
  pause
  exit /b 1
)

where git >nul 2>&1
if errorlevel 1 (
  echo [2/6] Gitをインストールします。確認画面が出たら許可してください...
  winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
  echo Git install exit code: !errorlevel!>>"%LOG_FILE%"
  if errorlevel 1 goto :install_error
) else (
  echo [2/6] Gitはインストール済みです。
)

where gh >nul 2>&1
if errorlevel 1 (
  echo [3/6] GitHub CLIをインストールします。確認画面が出たら許可してください...
  winget install --id GitHub.cli -e --source winget --accept-package-agreements --accept-source-agreements
  echo GitHub CLI install exit code: !errorlevel!>>"%LOG_FILE%"
  if errorlevel 1 goto :install_error
) else (
  echo [3/6] GitHub CLIはインストール済みです。
)

rem インストール直後でも、このBAT内からコマンドを認識できるようにする
set "PATH=%PATH%;%ProgramFiles%\Git\cmd;%ProgramFiles%\GitHub CLI"
where git >nul 2>&1 || goto :restart_required
where gh >nul 2>&1 || goto :restart_required

echo [4/6] GitHubへのログインを確認しています...
echo [4/6] Checking GitHub login...>>"%LOG_FILE%"
gh auth status >nul 2>&1
if errorlevel 1 (
  echo ブラウザが開きます。GitHubにログインし、表示される認証を完了してください。
  gh auth login --hostname github.com --git-protocol https --web
  if errorlevel 1 goto :auth_error
) else (
  echo GitHubにログイン済みです。
)

for /f "usebackq delims=" %%A in (`gh api user --jq ".login"`) do set "GITHUB_USER=%%A"
for /f "usebackq delims=" %%A in (`gh api user --jq ".id"`) do set "GITHUB_ID=%%A"
if not defined GITHUB_USER goto :auth_error
set "REPOSITORY=!GITHUB_USER!/%REPO_NAME%"
set "PUBLIC_URL=https://!GITHUB_USER!.github.io/%REPO_NAME%/"

echo [5/6] GitHubへサイトをアップロードしています...
echo [5/6] Uploading files...>>"%LOG_FILE%"
if not exist ".git" git init
git branch -M main
git config user.name >nul 2>&1 || git config user.name "!GITHUB_USER!"
git config user.email >nul 2>&1 || git config user.email "!GITHUB_ID!+!GITHUB_USER!@users.noreply.github.com"
git add index.html style.css favicon.svg README.md setup-and-publish.bat deploy-github-pages.sh
git diff --cached --quiet
if errorlevel 1 git commit -m "%COMMIT_MESSAGE%"

gh repo view "!REPOSITORY!" >nul 2>&1
if errorlevel 1 (
  gh repo create "!REPOSITORY!" --public --source=. --remote=origin
  if errorlevel 1 goto :upload_error
) else (
  git remote get-url origin >nul 2>&1
  if errorlevel 1 git remote add origin "https://github.com/!REPOSITORY!.git"
)
git push -u origin main
if errorlevel 1 goto :upload_error

echo [6/6] GitHub Pagesを有効にしています...
echo [6/6] Enabling GitHub Pages...>>"%LOG_FILE%"
gh api --method POST "repos/!REPOSITORY!/pages" -f "source[branch]=main" -f "source[path]=/" >nul 2>&1
if errorlevel 1 gh api --method PUT "repos/!REPOSITORY!/pages" -f "source[branch]=main" -f "source[path]=/" >nul 2>&1
if errorlevel 1 goto :pages_error

echo.
echo ========================================
echo 完了しました。反映には数分かかります。
echo !PUBLIC_URL!
echo Completed: !PUBLIC_URL!>>"%LOG_FILE%"
echo ========================================
start "" "!PUBLIC_URL!"
pause
exit /b 0

:install_error
echo ERROR: Installation failed.>>"%LOG_FILE%"
echo インストールに失敗しました。Windows Update後に再実行してください。
pause
exit /b 1

:restart_required
echo INFO: Restart required.>>"%LOG_FILE%"
echo インストールは完了しました。一度この画面を閉じ、BATをもう一度実行してください。
pause
exit /b 0

:auth_error
echo ERROR: Authentication failed.>>"%LOG_FILE%"
echo GitHubへのログインを完了できませんでした。BATをもう一度実行してください。
pause
exit /b 1

:upload_error
echo ERROR: Upload failed.>>"%LOG_FILE%"
echo GitHubへのアップロードに失敗しました。表示されたエラーを確認してください。
pause
exit /b 1

:pages_error
echo ERROR: Pages configuration failed.>>"%LOG_FILE%"
echo ファイルはアップロード済みですが、GitHub Pagesの有効化に失敗しました。
echo GitHubの Settings → Pages で main / root を選択してください。
pause
exit /b 1
