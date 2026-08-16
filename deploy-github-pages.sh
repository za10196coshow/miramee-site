#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "使い方: ./deploy-github-pages.sh GitHubユーザー名/リポジトリ名"
  exit 1
fi

repo="$1"
command -v git >/dev/null || { echo "gitが必要です。"; exit 1; }
command -v gh >/dev/null || { echo "GitHub CLI (gh) が必要です: https://cli.github.com/"; exit 1; }
gh auth status >/dev/null || { echo "先に gh auth login を実行してください。"; exit 1; }

if [ ! -d .git ]; then
  git init
fi
git branch -M main
git add index.html style.css favicon.svg README.md deploy-github-pages.sh
if ! git diff --cached --quiet; then
  git commit -m "Publish Miramee website"
fi

if ! gh repo view "$repo" >/dev/null 2>&1; then
  gh repo create "$repo" --public --source=. --remote=origin
elif ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "https://github.com/${repo}.git"
fi

git push -u origin main
if ! gh api --method POST "repos/${repo}/pages" -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1; then
  gh api --method PUT "repos/${repo}/pages" -f 'source[branch]=main' -f 'source[path]=/' >/dev/null
fi

owner="${repo%%/*}"
name="${repo##*/}"
echo "公開設定が完了しました。反映には数分かかります。"
echo "https://${owner}.github.io/${name}/"
