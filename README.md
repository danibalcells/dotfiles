# dotfiles

Personal shell configuration. One command to set up a new machine.

## Quick Start

    git clone https://github.com/danielbalcells/dotfiles ~/.dotfiles
    cd ~/.dotfiles
    ./install.sh

On macOS, this also installs Homebrew and packages from the Brewfile.

## What's Included

- **Zsh** config with autosuggestions and syntax highlighting
- **Starship** prompt (Powerline-style)
- **Git** config with sensible defaults
- **Vim** config with Vundle plugins and Monokai theme
- **Tmux** and **Screen** configs
- **Brewfile** for macOS package management

## Machine-Specific Config

Edit `~/.local.zsh` for per-machine settings (PATH additions, work email,
tool-specific config). This file is created from `local.zsh.example` on
first install and is not tracked in git.

## Structure

Each top-level directory is a symlink package. `install.sh` links its
contents into your home directory:

    zsh/.zshrc           → ~/.zshrc
    git/.gitconfig       → ~/.gitconfig
    vim/.vimrc           → ~/.vimrc
    vim/.vim/colors/     → ~/.vim/colors
    tmux/.tmux.conf      → ~/.tmux.conf
    screen/.screenrc     → ~/.screenrc
    starship/.config/... → ~/.config/starship.toml

## Testing

    make test

Runs the install in a Docker container to verify nothing is broken.
