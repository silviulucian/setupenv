
#!/usr/bin/env bash


# 
# Install apps
###############################################################################

#
# Install Xcode tools first

echo "Installing Xcode tools"

check=$((xcode-\select --install) 2>&1)
echo $check
str="xcode-select: note: install requested for command line developer tools"
while [[ "$check" == "$str" ]];
do
  sleep 1
  check=$((xcode-\select --install) 2>&1)
done

echo "Xcode tools seem to be installed"

#
# Install Homebrew and apps (see Brewfile for list of apps)

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
brew bundle # Install apps from Brewfile

#
# Install Node.js + packages

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash

export NVM_DIR="$HOME/.nvm"
export PATH="$NVM_DIR/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

nvm install --lts && nvm alias default 'lts/*'
curl -o- -L https://yarnpkg.com/install.sh | bash
yarn global add git-run create-react-app serverless

#
# Install Powerline fonts for Fish & co.

git clone https://github.com/powerline/fonts.git --depth=1
cd fonts && ./install.sh
cd .. && rm -rf fonts

#
# Misc

curl -L https://iterm2.com/misc/install_shell_integration.sh | bash
open -a '/usr/local/Caskroom/adobe-creative-cloud/latest/Creative Cloud Installer.app'


#
# Settings
###############################################################################

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#
# macOS settings

source macos/settings.sh

#
# Make Fish the default shell

echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
chsh -s `which fish`