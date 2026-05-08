#!/usr/bin/env bash

# update system, install apps and dependencies
# echo "updating system"
# sudo pacman -Syu --noconfirm
echo "installing apps & dependencies"
sudo pacman -S --noconfirm \
	base-devel ripgrep fzf go neovim tmux alacritty  firefox nvm \
	jre8-openjdk-headless jre8-openjdk jdk8-openjdk openjdk8-doc openjdk8-src \
	jre17-openjdk-headless jre17-openjdk jdk17-openjdk openjdk17-doc \
	openjdk17-src

# set default java versjion
echo "set java-17 as default"
sudo archlinux-java set java-17-openjdk

# check if config floder exists
if [ ! -d "$HOME/.config" ]; then
	echo "creating .config directory"
	mkdir -p "$HOME/.config"
fi

# create symlink fo configs
echo "creating symlink for configs"
ln -s $HOME/.dotfiles/bin/ $HOME/.local/bin
ln -s $HOME/.dotfiles/tmux/ $HOME/.config/tmux
ln -s $HOME/.dotfiles/nvim/ $HOME/.config/nvim
ln -s $HOME/.dotfiles/alacritty/ $HOME/.config/alacritty

# install fonts
echo "installing fonts"

FONTS_DIR=$HOME/.local/share/fonts

if [ ! -d "$FONTS_DIR" ]; then
	echo "creating fonts directory"
	mkdir -p "$FONTS_DIR"
fi

tar xzf $HOME/.dotfiles/fonts/SourceCodePro.tar.gz -C "$FONTS_DIR"
chmod 555 "$FONTS_DIR"/*
fc-cache

# update env
echo "updating env"
echo 'source /usr/share/nvm/init-nvm.sh' >> $HOME/.bashrc
echo 'export PATH=$HOME/.local/bin/:$PATH' >> $HOME/.bashrc

# install latest nodejs LTS version
source /usr/share/nvm/init-nvm.sh
nvm install --lts
nvm use --lts
