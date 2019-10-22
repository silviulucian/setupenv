#!/usr/bin/env bash

# cd into this script's dir
cd "$(dirname "${BASH_SOURCE}")"

#
# OS-specific setup
###############################################################################

FIRST_TIME=false
if ! [ -f ~/setupenv.lock ]; then
  FIRST_TIME=true
  [[ "$OSTYPE" == "darwin"* ]] && source macos/setup.sh
  touch ~/setupenv.lock
fi


#
# Sync dotfiles
###############################################################################

#
# Update repos

public_repos=( dotfiles )
for pub in "${public_repos[@]}"
do
  :
  pub_dir="./$pub"
  [[ -d $pub_dir ]] || git clone "git@github.com:silviulucian/$pub.git"
  cd $pub_dir
  git pull origin master
  cd ..
done

git pull origin master # Update self

#
# Sync

rsync_sources=( dotfiles extras )
for src in "${rsync_sources[@]}"
do
  :
  [[ -d $src ]] && rsync --exclude-from .rsyncignore -avh --no-perms $src/ ~
done

#
# Extras

# Create home bin dir

[[ -d ~/bin ]] || mkdir ~/bin

# Fix SSH permissions

chmod 400 ~/.ssh/*
chmod 600 ~/.ssh/config ~/.ssh/known_hosts


#
# Finished

[[ $FIRST_TIME ]] || echo "You may need to restart for some changes to take effect."
