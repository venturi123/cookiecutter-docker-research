#!/bin/bash


if [ ! -d ".git" ]; then
  printf "\033[0;31mThis directory is not a Git repository. Please run the following commands to initialize a Git repository and link it to GitHub:\033[0m\n"
  printf "  \033[0;32mgit init\033[0m\n"
  printf "  \033[0;32mgit remote add origin <your-repo-url>\033[0m\n"
  exit 1
fi

# Check if there are changes to be committed
if [[ -n $(git status -s) ]]; then
  # Add changes
  git add .
  if [ $? -ne 0 ]; then
    printf "\033[0;31mAdd failed.\033[0m\n"  # Red text
    exit 1
  fi

  # Commit changes
  git commit -m "Regular backup"
  if [ $? -ne 0 ]; then
    printf "\033[0;31mCommit failed.\033[0m\n"  # Red text
    exit 1
  fi

  # Push changes
  git push
  if [ $? -ne 0 ]; then
    printf "\033[0;31mPush failed.\033[0m\n"  # Red text
    exit 1
  fi

  printf "\033[0;32mPush complete. Backup successful.\033[0m\n"  # Green text
else
  printf "\033[0;33mNo changes to commit.\033[0m\n"  # Yellow text
fi


