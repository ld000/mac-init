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
  read -n 1 -p 'Press [Enter] when install complate.'
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

config_git() {
  cat <<'EOF' > ~/.gitconfig
[user]
	name = ld000
	email = lidong9144@163.com
[core]
	editor = vim
EOF
}

config_vim() {
  wget http://static.tjx.be/vim-vide.tgz && tar xvf ./vim-vide.tgz -C ~
}

setup_java() {
  cat <<'EOF' >> ~/.zshrc

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-13.0.1.jdk/Contents/Home 
export JRE_HOME=${JAVA_HOME}/jre  
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib  
export PATH=${JAVA_HOME}/bin:$PATH
EOF
}

setup_go() {
  download_url=https://dl.google.com/go/go1.13.3.darwin-amd64.pkg
  pkg_file=${download_url##*/}
  curl -LO $download_url
  sudo installer -pkg $pkg_file -target /
  rm $pkg_file

  cat <<'EOF' >> ~/.zshrc

export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export GO111MODULE=auto
export GOPROXY=https://goproxy.cn
EOF

  cat <<'EOF' >> ~/.bash_profile

export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export GO111MODULE=auto
export GOPROXY=https://goproxy.cn
EOF

  source ~/.bash_profile
  mkdir -p $GOPATH
}

setup_js() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash
  echo '' >> ~/.zshrc
  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
  echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm' >> ~/.zshrc
  echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.zshrc
  source ~/.bash_profile

  nvm install 4
  nvm install 6
  nvm install 8

  npm install --global yrm --registry=https://registry.npm.taobao.org

  yrm use cnpm
  npm i -g yarn
}

setup_ssh() {
  ssh-keygen -C lidong9144@163.com
  cat ~/.ssh/id_rsa.pub
}

show_hide_file() {
  defaults write com.apple.Finder AppleShowAllFiles YES;KillAll Finder
}

setup_maven() {
  download_url=https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz
  tar_file=${download_url##*/}
  curl -LO $download_url
  tar xzvf ./apache-maven-3.6.2-bin.tar.gz
  mv apache-maven-3.6.2 ~/depend/
  rm -rf apache-maven-3.6.2-bin.tar.gz

  cat <<'EOF' >> ~/.zshrc

export MAVEN_PATH=$HOME/depend/apache-maven-3.6.2
export PATH=$PATH:$MAVEN_PATH/bin
EOF
}

setup_font() {
  brew tap homebrew/cask-fonts
  brew install font-fira-code
}

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\\n$fmt\\n" "$@"
}

# run function
hide_dock_automatically
show_hide_file

install_xcode_cmdline_tools

install_oh_my_zsh

prepare_folders

setup_homebrew
bundle_homebrew

# mysql should start on launch
# ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents

setup_go
setup_js

config_git
config_vim
setup_java
setup_maven
setup_ssh
setup_font

# Hold my own hand to make sure I finish configuring.
echo "Don't forget that you need to:
1. Add your ssh keys (you put them in your secret hiding place)."
read -n 1 -p 'Press [Enter] when you have added your ssh key.'
echo "2. source ~/.zshrc"
read -n 1 -p 'Press [Enter] when you have execute the command.'
