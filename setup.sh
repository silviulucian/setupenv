#!/usr/bin/env bash

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This doesn't seem to be macOS"
  exit 1
fi

ARG=${1:-base}

# cd into this script's dir
cd "$(dirname "${BASH_SOURCE}")"

# Update self
git pull origin master


#
# Install Xcode tools
###############################################################################

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
# Install Homebrew
###############################################################################

if [[ ! -x "$(command -v brew)" ]]; then
  echo "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
else
  echo "Homebrew installed"
  brew update
  brew upgrade
fi


#
# Install base set of apps
###############################################################################

brew bundle --file=Brewfile-base
[[ ! -d "/Applications/Adobe Creative Cloud" ]] && open -a "/usr/local/Caskroom/adobe-creative-cloud/latest/Creative Cloud Installer.app"


#
# Install dev apps
###############################################################################

if [[ "$ARG" == "dev" ]]; then
  brew bundle --file=Brewfile-dev

  # Install NVM, Node.js and packages
  if [[ ! -d "$HOME/.nvm" ]]; then
    echo "Installing NVM and Node.js"

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    export PATH="$NVM_DIR/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    nvm install 12
    nvm alias default 12
    curl -o- -L https://yarnpkg.com/install.sh | bash
  else
    echo "NVM and Node.js installed"
  fi

  yarn global upgrade
  yarn global add git-run create-react-app gatsby-cli serverless

  # Install Powerline fonts
  if [[ ! -f "$HOME/Library/Fonts/Ubuntu Mono derivative Powerline.ttf" ]]; then
    echo "Installing Powerline fonts"

    git clone https://github.com/powerline/fonts.git --depth=1
    cd fonts
    ./install.sh
    cd ..
    rm -rf fonts
  else
    echo "Powerline fonts installed"
  fi

  # Make Fish the default shell
  if ! grep -q "fish" "/etc/shells"; then
    echo "Making Fish the default shell"

    echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
    chsh -s `which fish`
  else
    echo "Fish is already the default shell"
  fi

  # Sync dotfiles and secrets
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
fi


#
# Change settings
###############################################################################

if [[ ! -f ~/settings.lock ]]; then
  echo "Changing settings"

  source settings.sh
  touch ~/settings.lock

  echo "You may need to restart for some changes to take effect"
else
  echo "Settings already changed"
fi
