#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

# 심볼릭 링크 생성
ln -sf "$DIR/.bashrc" ~/
ln -sf "$DIR/.Xmodmap" ~/
ln -sf "$DIR/.xprofile" ~/

mkdir -p ~/.config/xfce4/terminal
ln -sf "$DIR/terminal/terminalrc" ~/.config/xfce4/terminal/

mkdir -p ~/.config/nvim/templates
ln -sf "$DIR/nvim/init.lua" ~/.config/nvim/
for f in "$DIR"/nvim/templates/*; do
    ln -sf "$f" ~/.config/nvim/templates/
done

mkdir -p ~/.config/fcitx5
ln -sf "$DIR/fcitx5/config" ~/.config/fcitx5/

mkdir -p ~/.config/fontconfig
ln -sf "$DIR/fontconfig/fonts.conf" ~/.config/fontconfig/

mkdir -p ~/.config/gtk-3.0
ln -sf "$DIR/gtk-3.0/gtk.css" ~/.config/gtk-3.0/

echo "dotfiles 설치 완료"
