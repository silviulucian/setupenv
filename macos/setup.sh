#!/usr/bin/env bash

# Install Xcode tools first
xcode-select --install


#
# Install Homebrew and apps (see Brewfile for list of apps)
###############################################################################

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null

# ^--- Note: macOS doesn't come with git-lfs (even after installing Xcode tools)
# so the above is going to fail because .gitattributes (the one in the dotfiles
# repo) references git-lfs. To fix, simply comment out those few lines in your
# ~/.giattributes and undo once Homebrew is installed

brew bundle # Install apps from Brewfile

# Postgres
createuser -s postgres # dropuser postgres to remove
brew services start postgres #

# Powerline fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts && ./install.sh
cd .. && rm -rf fonts

# Make Fish the default shell
echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
chsh -s `which fish`

# Misc
curl -L https://iterm2.com/misc/install_shell_integration.sh | bash
open -a '/usr/local/Caskroom/adobe-creative-cloud/latest/Creative Cloud Installer.app'


#
# Install Node + packages
###############################################################################

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

export NVM_DIR="$HOME/.nvm"
export PATH="$NVM_DIR/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

nvm install --lts && nvm alias default 'lts/*'

curl -o- -L https://yarnpkg.com/install.sh | bash

yarn global add eslint prettier markmon git-run create-react-app serverless


#
# Install Ruby + gems
###############################################################################

curl -sSL "https://rvm.io/mpapis.asc" | gpg --import -
curl -sSL "https://rvm.io/pkuczynski.asc" | gpg --import -
curl -sSL "https://get.rvm.io" | bash -s stable --ruby

export RVM_DIR="$HOME/.rvm"
export PATH="$RVM_DIR/bin:$PATH"
[[ -s "$RVM_DIR/scripts/rvm" ]] && source "$RVM_DIR/scripts/rvm"

gem install rails bundle rubocop


#
# Install Python's PIP + packages
###############################################################################

sudo easy_install pip

sudo pip install -U CodeIntel


source settings.sh
