#!/usr/bin/env bash

#
# Sync dotfiles and secrets
#------------------------------------------------------------------------------

repos=( dotfiles secrets )
for repo in "${repos[@]}"
do
  :
  repo_dir="./$repo"
  [[ ! -d $repo_dir ]] && git clone "git@github.com:silviulucian/$repo.git"
  cd $repo_dir
  git pull origin master
  cd ..
  rsync --exclude-from .rsyncignore -avh --no-perms $repo_dir/ ~
done

# Fix SSH permissions
chmod 400 ~/.ssh/*
chmod 600 ~/.ssh/config ~/.ssh/known_hosts
