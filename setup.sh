#!/usr/bin/env bash

# cd into this script's dir
cd "$(dirname "${BASH_SOURCE}")"


#
# Update repos
###############################################################################

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

# Update self
git pull origin master


#
# Setup files
###############################################################################

rsync_sources=( dotfiles extras )
for src in "${rsync_sources[@]}"
do
  :
  rsync --exclude-from .rsyncignore \
    -avh --no-perms $src/ ~
done

[ -f extras.sh ] || source extras.sh


#
# OS-specific setup
###############################################################################

if ! [ -f ~/setupenv.lock ]; then
  [[ "$OSTYPE" == "darwin"* ]] && source macos/setup.sh
  touch ~/setupenv.lock
fi
