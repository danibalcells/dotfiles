#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf "\033[0;34m[dotfiles]\033[0m %s\n" "$1"; }
ok()   { printf "\033[0;32m[dotfiles]\033[0m %s\n" "$1"; }
warn() { printf "\033[0;33m[dotfiles]\033[0m %s\n" "$1"; }

if [[ $EUID -eq 0 ]]; then
    SUDO=""
elif command -v sudo &>/dev/null; then
    SUDO="sudo"
else
    SUDO=""
fi

INSTALL_VIM=false
INSTALL_OBSIDIAN=false
for arg in "$@"; do
    case "$arg" in
        --vim)      INSTALL_VIM=true ;;
        --nvim)     ;;  # deprecated — nvim is installed by default now
        --obsidian) INSTALL_OBSIDIAN=true ;;
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

if [[ "$(uname)" == "Linux" ]] && command -v apt-get &>/dev/null; then
    NEED_APT=()
    command -v tmux       &>/dev/null || NEED_APT+=(tmux)
    command -v screen     &>/dev/null || NEED_APT+=(screen)
    command -v locale-gen &>/dev/null || NEED_APT+=(locales)
    if (( ${#NEED_APT[@]} > 0 )); then
        info "Installing apt packages: ${NEED_APT[*]}"
        $SUDO apt-get update
        $SUDO apt-get install -y "${NEED_APT[@]}"
    fi

    if ! locale -a 2>/dev/null | grep -qi '^en_US\.utf8$'; then
        info "Generating en_US.UTF-8 locale..."
        $SUDO locale-gen en_US.UTF-8
        $SUDO update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
    fi
elif ! command -v tmux &>/dev/null && command -v brew &>/dev/null; then
    brew install tmux
fi

# Linux: install up-to-date nvim, fzf, tree-sitter from upstream releases
# (apt versions are too old for our nvim config + fzf-lua + nvim-treesitter).
nvim_ok() {
    command -v nvim &>/dev/null || return 1
    local v
    v=$(nvim --version | head -1 | awk '{print $2}' | tr -d 'v')
    [[ "$v" =~ ^([0-9]+)\.([0-9]+) ]] || return 1
    (( BASH_REMATCH[1] > 0 || BASH_REMATCH[2] >= 10 ))
}

install_nvim_linux() {
    nvim_ok && return
    info "Installing latest Neovim AppImage..."
    local tmp
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/nvim.appimage" \
        https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
    chmod +x "$tmp/nvim.appimage"
    if "$tmp/nvim.appimage" --version &>/dev/null; then
        $SUDO mv "$tmp/nvim.appimage" /usr/local/bin/nvim
    else
        (cd "$tmp" && ./nvim.appimage --appimage-extract >/dev/null)
        $SUDO rm -rf /opt/nvim
        $SUDO mv "$tmp/squashfs-root" /opt/nvim
        $SUDO ln -sf /opt/nvim/AppRun /usr/local/bin/nvim
    fi
    rm -rf "$tmp"
}

fzf_ok() {
    command -v fzf &>/dev/null || return 1
    local v
    v=$(fzf --version | awk '{print $1}')
    [[ "$v" =~ ^([0-9]+)\.([0-9]+) ]] || return 1
    (( BASH_REMATCH[1] > 0 || BASH_REMATCH[2] >= 36 ))
}

install_fzf_linux() {
    fzf_ok && return
    info "Installing fzf v0.55.0..."
    local v=0.55.0
    local tmp
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/fzf.tgz" \
        "https://github.com/junegunn/fzf/releases/download/v${v}/fzf-${v}-linux_amd64.tar.gz"
    tar -xzf "$tmp/fzf.tgz" -C "$tmp"
    $SUDO mv "$tmp/fzf" /usr/local/bin/fzf
    rm -rf "$tmp"
}

install_tree_sitter_linux() {
    command -v tree-sitter &>/dev/null && return
    info "Installing tree-sitter CLI v0.22.6..."
    local v=0.22.6
    local tmp
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/ts.gz" \
        "https://github.com/tree-sitter/tree-sitter/releases/download/v${v}/tree-sitter-linux-x64.gz"
    gunzip -f "$tmp/ts.gz"
    chmod +x "$tmp/ts"
    $SUDO mv "$tmp/ts" /usr/local/bin/tree-sitter
    rm -rf "$tmp"
}

if [[ "$(uname)" == "Linux" ]]; then
    install_nvim_linux
    install_fzf_linux
    install_tree_sitter_linux
fi

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    info "Cloning tmux plugin manager (tpm)..."
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

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
symlink "$DOTFILES_DIR/zsh/dircolors"                  "$HOME/.dircolors"
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

# Cursor
symlink_dir_contents() {
    local src_dir="$1" dest_dir="$2"
    mkdir -p "$dest_dir"
    find "$src_dir" -maxdepth 1 -mindepth 1 | while read -r item; do
        local name dest
        name="$(basename "$item")"
        dest="$dest_dir/$name"
        if [[ -d "$item" ]]; then
            [[ -e "$dest" || -L "$dest" ]] && rm -rf "$dest"
        else
            [[ -e "$dest" || -L "$dest" ]] && rm "$dest"
        fi
        ln -s "$item" "$dest"
        ok "Linked $dest → $item"
    done
}

CURSOR_DIR="$HOME/.cursor"
mkdir -p "$CURSOR_DIR/rules" "$CURSOR_DIR/skills"

symlink "$DOTFILES_DIR/cursor/skills-cursor" "$CURSOR_DIR/skills-cursor"
symlink "$DOTFILES_DIR/cursor/mcp.json"      "$CURSOR_DIR/mcp.json"
symlink_dir_contents "$DOTFILES_DIR/cursor/rules"  "$CURSOR_DIR/rules"
symlink_dir_contents "$DOTFILES_DIR/cursor/skills" "$CURSOR_DIR/skills"

symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
info "Neovim config linked. Open nvim and let lazy.nvim install plugins."

if [[ "$INSTALL_OBSIDIAN" == true ]]; then
    symlink_dir_contents "$DOTFILES_DIR/cursor/optional/obsidian/rules"  "$CURSOR_DIR/rules"
    symlink_dir_contents "$DOTFILES_DIR/cursor/optional/obsidian/skills" "$CURSOR_DIR/skills"
fi

if [[ "$(uname)" == "Darwin" ]]; then
    CURSOR_USER="$HOME/Library/Application Support/Cursor/User"
    mkdir -p "$CURSOR_USER"
    symlink "$DOTFILES_DIR/cursor/settings.json"    "$CURSOR_USER/settings.json"
    symlink "$DOTFILES_DIR/cursor/keybindings.json" "$CURSOR_USER/keybindings.json"
fi

if command -v zsh &>/dev/null; then
    ZSH_PATH=$(command -v zsh)
    CURRENT_SHELL=$(getent passwd "$USER" 2>/dev/null | cut -d: -f7 || echo "$SHELL")
    if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
        if grep -qx "$ZSH_PATH" /etc/shells 2>/dev/null; then
            info "Setting login shell to $ZSH_PATH..."
            chsh -s "$ZSH_PATH" || warn "chsh failed — set login shell to zsh manually"
        else
            warn "$ZSH_PATH not in /etc/shells — set login shell to zsh manually"
        fi
    fi
fi

ok "Done! Restart your shell or run: exec zsh"
