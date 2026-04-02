#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf "\033[0;34m[dotfiles]\033[0m %s\n" "$1"; }
ok()   { printf "\033[0;32m[dotfiles]\033[0m %s\n" "$1"; }
warn() { printf "\033[0;33m[dotfiles]\033[0m %s\n" "$1"; }

INSTALL_VIM=false
for arg in "$@"; do
    case "$arg" in
        --vim) INSTALL_VIM=true ;;
    esac
done

if [[ "$(uname)" == "Darwin" ]]; then
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        info "Installing Homebrew packages..."
        brew bundle --file="$DOTFILES_DIR/Brewfile"
    fi
fi

if ! command -v starship &>/dev/null; then
    info "Installing Starship prompt..."
    if command -v brew &>/dev/null; then
        brew install starship
    else
        mkdir -p "$HOME/.local/bin"
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
    fi
fi

if ! command -v uv &>/dev/null; then
    info "Installing uv..."
    if command -v brew &>/dev/null; then
        brew install uv
    else
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
fi

if [[ ! -d "$HOME/.pyenv" ]]; then
    info "Installing pyenv..."
    if command -v brew &>/dev/null; then
        brew install pyenv
    else
        curl -fsSL https://pyenv.run | bash
    fi
fi

export NVM_DIR="$HOME/.nvm"
if [[ ! -d "$NVM_DIR" ]]; then
    info "Installing nvm..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    source "$NVM_DIR/nvm.sh"
    info "Installing latest Node LTS via nvm..."
    nvm install --lts
fi

ZSH_PLUGINS_DIR="$HOME/.zsh/plugins"
mkdir -p "$ZSH_PLUGINS_DIR"

clone_plugin() {
    local repo="$1" dest="$2"
    if [[ ! -d "$dest" ]]; then
        info "Cloning $repo..."
        git clone --depth 1 "$repo" "$dest"
    fi
}

clone_plugin https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"

symlink() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [[ -L "$dest" ]]; then
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        warn "Backing up existing $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi
    ln -s "$src" "$dest"
    ok "Linked $dest → $src"
}

symlink "$DOTFILES_DIR/zsh/.zshrc"                    "$HOME/.zshrc"
symlink "$DOTFILES_DIR/git/.gitconfig"                 "$HOME/.gitconfig"
symlink "$DOTFILES_DIR/tmux/.tmux.conf"                "$HOME/.tmux.conf"
symlink "$DOTFILES_DIR/screen/.screenrc"               "$HOME/.screenrc"
symlink "$DOTFILES_DIR/starship/.config/starship.toml" "$HOME/.config/starship.toml"

if [[ "$INSTALL_VIM" == true ]]; then
    symlink "$DOTFILES_DIR/vim/.vimrc"      "$HOME/.vimrc"
    symlink "$DOTFILES_DIR/vim/.vim/colors" "$HOME/.vim/colors"

    VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"
    if [[ ! -d "$VUNDLE_DIR" ]]; then
        info "Installing Vundle..."
        git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"
    fi
    info "Installing Vim plugins..."
    vim +PluginInstall +qall 2>/dev/null || warn "Vim plugin install had warnings (non-fatal)"
fi

if [[ ! -f "$HOME/.local.zsh" ]]; then
    cp "$DOTFILES_DIR/local.zsh.example" "$HOME/.local.zsh"
    info "Created ~/.local.zsh from template — edit it for this machine"
fi

ok "Done! Restart your shell or run: exec zsh"
