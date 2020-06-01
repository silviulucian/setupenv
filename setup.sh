#!/usr/bin/env bash

set -x;

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This doesn't seem to be macOS"
  exit 1
fi

# cd into this script's dir
cd "$(dirname "${BASH_SOURCE}")"

# Update self
git pull origin master


#
# Install Xcode tools
#------------------------------------------------------------------------------

check=$((xcode-\select --install) 2>&1)
str="xcode-select: note: install requested for command line developer tools"
[[ "$check" == "$str" ]] && echo "Installing Xcode tools"
while [[ "$check" == "$str" ]];
do
  sleep 1
  check=$((xcode-\select --install) 2>&1)
done

echo "Xcode tools installed"


#
# Install Oh My Zsh
#------------------------------------------------------------------------------

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing Oh My Zsh"

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh installed"
fi


#
# Install Homebrew
#------------------------------------------------------------------------------

if [[ ! -x "$(command -v brew)" ]]; then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
  echo "Homebrew installed"
  brew update
  brew upgrade
fi


#
# Install apps
#------------------------------------------------------------------------------

brew bundle --file=Brewfile

# Install NVM and Node.js
if [[ ! -d "$HOME/.nvm" ]]; then
  echo "Installing NVM and Node.js"

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

  export NVM_DIR="$HOME/.nvm"
  export PATH="$NVM_DIR/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

  nvm install 12
  nvm alias default 12
  curl -o- -L https://yarnpkg.com/install.sh | bash
elseasdf
  echo "NVM and Node.js installed"
fi

# Node.js packages
yarn global add \
  @vue/cli \
  list-repos \
  git-run

yarn global upgrade

# Install PHP extensions
pecl install \
  redis
  yaml

# Install Composer
if [[ ! -f /usr/local/bin/composer ]]; then
  echo "Installing Composer"
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
else
  echo "Composer installed"
fi

# Composer packages
composer global require \
  laravel/installer \
  laravel/vapor-cli

composer global upgrade


#
# Sync dotfiles
#------------------------------------------------------------------------------

source sync-dotfiles.sh


#
# Change settings
#------------------------------------------------------------------------------

if [[ ! -f ~/settings.lock ]]; then
  echo "Changing settings"

  source settings.sh
  touch ~/settings.lock

  echo "You may need to restart for some changes to take effect"
else
  echo "Settings already changed"
fi
