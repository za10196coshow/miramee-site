# Miramee GitHub Pages版

ビルド不要の静的サイトです。`index.html`、`style.css`、`favicon.svg`だけで動作します。

## いちばん簡単な公開方法（Windows）

1. ZIPを右クリックして「すべて展開」します。
2. `START-HERE.bat`をダブルクリックします。
3. 初回だけブラウザでGitHubにログインします。

黒い画面が開いたままになり、現在の処理が `[1/6]`〜`[6/6]`で表示されます。BATがGit、GitHub CLIの確認・インストール、認証、リポジトリ作成、アップロード、GitHub Pagesの有効化まで行います。GitHubアカウントは事前に作成しておいてください。

途中で問題が起きた場合は、同じフォルダに `miramee-publish.log` が作成されます。

数分後、次のURLで公開されます。

```text
https://あなたのGitHubユーザー名.github.io/miramee-site/
```

リポジトリ名を変える場合は、BAT上部の `REPO_NAME=miramee-site` を編集します。

## macOS・Linuxの場合

GitとGitHub CLIを導入後、次を実行します。

```bash
gh auth login
chmod +x deploy-github-pages.sh
./deploy-github-pages.sh あなたのGitHubユーザー名/miramee-site
```

## GitHubの画面から公開する方法

1. GitHubで新しいPublicリポジトリを作成します。
2. ZIP内のファイルをすべてリポジトリ直下へアップロードします。
3. `Settings` → `Pages`を開きます。
4. `Build and deployment`を`Deploy from a branch`にします。
5. Branchを`main`、フォルダを`/(root)`にして保存します。

## ローカルで確認

`index.html`をダブルクリックするだけでも表示できます。簡易サーバーを使う場合：

```bash
python3 -m http.server 8000
```

ブラウザで `http://localhost:8000` を開きます。

## 更新方法

ファイルを編集した後、以下を実行します。

```bash
git add .
git commit -m "Update site"
git push
```

`main`ブランチへの反映後、GitHub Pagesも自動更新されます。
