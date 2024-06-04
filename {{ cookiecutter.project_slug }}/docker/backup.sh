#!/bin/bash


if [ ! -d ".git" ]; then
  printf "\033[0;31mThis directory is not a Git repository. Please run the following commands to initialize a Git repository and link it to GitHub:\033[0m\n"
  printf "  \033[0;32mgit init\033[0m\n"
  printf "  \033[0;32mgit remote add origin <your-repo-url>\033[0m\n"
  exit 1
fi

if [[ -n $(git status -s) ]]; then
  git add .
  git commit -m "Regular backup"
  git push
  printf "\033[0;32mPush complete. Backup successful.\033[0m\n"
else
  printf "No changes detected, no commit made.\n"
fi

