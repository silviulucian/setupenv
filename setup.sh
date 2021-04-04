#!/usr/bin/env bash

#set -x;

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This doesn't seem to be macOS"
  exit 1
fi

# cd into this script's dir
cd "$(dirname "${BASH_SOURCE}")"

# Update self
git pull origin master


#
# Install Xcode tools & Rosetta 2
#------------------------------------------------------------------------------

check=$((xcode-\select --install) 2>&1)
str="xcode-select: note: install requested for command line developer tools"
[[ "$check" == "$str" ]] && echo "Installing Xcode tools and Rosetta 2"
while [[ "$check" == "$str" ]];
do
  sleep 1
  sudo softwareupdate --install-rosetta
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
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew installed"
  brew update
  brew upgrade
fi


#
# Install apps
#------------------------------------------------------------------------------

brew bundle

# Install NVM and Node.js
if [[ ! -d "$HOME/.nvm" ]]; then
  echo "Installing NVM and Node.js"

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

  export NVM_DIR="$HOME/.nvm"
  export PATH="$NVM_DIR/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

  nvm install 14
  nvm alias default 14
  curl -o- -L https://yarnpkg.com/install.sh | bash
else
  echo "NVM and Node.js installed"
fi	

# Node.js packages
yarn global add \
  list-repos
  # @vue/cli \

yarn global upgrade

# Install PHP 7.4
brew install php@7.4

# Install PHP extensions
# pecl install \
#   redis \
#   yaml \
#   zip

# Install Composer
# if [[ ! -f /usr/local/bin/composer ]]; then
#   echo "Installing Composer"
#   php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#   php composer-setup.php
#   php -r "unlink('composer-setup.php');"
#   mv composer.phar /usr/local/bin/composer
# else
#   echo "Composer installed"
# fi

# Composer packages
composer global require \
  laravel/installer

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
