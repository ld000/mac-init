#!/bin/sh

set -e

hide_dock_automatically() {
  /usr/bin/osascript - <<'EOF'
tell application "System Preferences"
    activate
    set current pane to pane "com.apple.preference.dock"
end tell
tell application "System Events" to tell process "System Preferences"
    tell window "Dock"
        set theCheckbox to checkbox "自动显示和隐藏 Dock"  —- Automatically hide and show the Dock
        tell theCheckbox
            set checkboxStatus to value of theCheckbox as boolean
            if not checkboxStatus then click theCheckbox
        end tell
    end tell
end tell
delay 0.5
tell application "System Preferences" to quit
EOF
}

install_xcode_cmdline_tools() {
  xcode-select --install
}

install_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

setup_homebrew() {
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" && brew update
}

bundle_homebrew() {
  brew bundle --file="./Brewfile"
}

prepare_folders() {
  mkdir -p ~/workspace/github
  mkdir -p ~/workspace/github-self
}

setup_java() {

}

setup_go() {

}

setup_js() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash
  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
  echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm' >> ~/.zshrc
  source ~/.zshrc

  nvm install 4
  nvm install 6
  nvm install 8

  npm install --global yrm --registry=https://registry.npm.taobao.org

  yrm use cnpm
  npm i -g yarn
}

setup_ssh() {
  ssh-keygen
  cat ~/.ssh/id_rsa.pub
}

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\\n$fmt\\n" "$@"
}

# run function
hide_dock_automatically

install_xcode_cmdline_tools

install_oh_my_zsh

prepare_folders

setup_homebrew
bundle_homebrew

# mysql should start on launch
ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents

setup_java
setup_go
setup_js

# Hold my own hand to make sure I finish configuring.
echo "Don't forget that you need to:
1. Add your ssh keys (you put them in your secret hiding place)."
pause 'Press [Enter] when you have added your ssh key.'
