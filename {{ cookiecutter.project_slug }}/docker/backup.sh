#!/bin/bash

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
  printf "\033[0;33mInitializing git repository...\033[0m\n"
  git init
  if [ $? -ne 0 ]; then
    printf "\033[0;31mGit initialization failed.\033[0m\n"
    exit 1
  fi
  printf "\033[0;32mGit repository initialized successfully.\033[0m\n"
fi

# Check if there are changes to be committed
if [[ -n $(git status -s) ]]; then
  # Add changes
  git add .
  if [ $? -ne 0 ]; then
    printf "\033[0;31mAdd failed.\033[0m\n"
    exit 1
  fi

  # Commit changes with custom message if provided, otherwise use default
  COMMIT_MSG=${1:-"Regular backup"}
  git commit -m "$COMMIT_MSG"
  if [ $? -ne 0 ]; then
    printf "\033[0;31mCommit failed.\033[0m\n"
    exit 1
  fi
  printf "\033[0;32mLocal backup successful.\033[0m\n"
  
  # Show instructions for pushing to remote
  printf "\033[0;33mTo push to remote repository, use these commands:\033[0m\n"
  printf "  \033[0;36m# Add remote repository if not configured:\033[0m\n"
  printf "  \033[0;32mgit remote add origin <your-repo-url>\033[0m\n"
  printf "  \033[0;36m# Push to remote:\033[0m\n"
  printf "  \033[0;32mgit push\033[0m\n"
else
  printf "\033[0;33mNo changes to commit.\033[0m\n"
fi
