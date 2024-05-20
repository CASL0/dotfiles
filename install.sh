#!/bin/bash
set -e

# Homebrewのインストール
if test ! "$(command -v brew)"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew bundle --file ./Brewfile

# asdfのプラグインインストール
asdf plugin-add python
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin-add java https://github.com/halcyon/asdf-java.git
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git

# dotfileのシンボリックリンク
DOT_FILES=(
    ".bash_profile"
    ".bashrc"
)
for file in "${DOT_FILES[@]}"; do
    ln -sf "$(pwd)/$file" ~
done
