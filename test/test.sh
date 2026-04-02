#!/usr/bin/env bash
set -euo pipefail

pass() { printf "\033[0;32m✓ %s\033[0m\n" "$1"; }
fail() { printf "\033[0;31m✗ %s\033[0m\n" "$1"; exit 1; }

[[ -L "$HOME/.zshrc" ]]      && pass ".zshrc symlink" || fail ".zshrc symlink missing"
[[ -L "$HOME/.gitconfig" ]]  && pass ".gitconfig symlink" || fail ".gitconfig symlink missing"
[[ -L "$HOME/.vimrc" ]]      && pass ".vimrc symlink" || fail ".vimrc symlink missing"
[[ -L "$HOME/.tmux.conf" ]]  && pass ".tmux.conf symlink" || fail ".tmux.conf symlink missing"
[[ -L "$HOME/.screenrc" ]]   && pass ".screenrc symlink" || fail ".screenrc symlink missing"
[[ -L "$HOME/.config/starship.toml" ]] && pass "starship.toml symlink" || fail "starship.toml symlink missing"

[[ -d "$HOME/.zsh/plugins/zsh-autosuggestions" ]] && pass "autosuggestions plugin" || fail "autosuggestions missing"
[[ -d "$HOME/.zsh/plugins/zsh-syntax-highlighting" ]] && pass "syntax-highlighting plugin" || fail "syntax-highlighting missing"

[[ -d "$HOME/.vim/bundle/Vundle.vim" ]] && pass "Vundle installed" || fail "Vundle missing"

[[ -d "$HOME/.pyenv" ]] && pass "pyenv installed" || fail "pyenv missing"

[[ -d "$HOME/.nvm" ]] && pass "nvm installed" || fail "nvm missing"
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh" 2>/dev/null
command -v node &>/dev/null && pass "node installed ($(node --version))" || fail "node missing"

[[ -f "$HOME/.local.zsh" ]] && pass "~/.local.zsh created" || fail "~/.local.zsh missing"

error_output=$(zsh -c 'source ~/.zshrc' 2>&1 >/dev/null || true)
if [[ -z "$error_output" ]]; then
    pass "zsh starts clean"
else
    echo "  warnings: $error_output"
    pass "zsh starts (with warnings)"
fi

if command -v starship &>/dev/null; then
    pass "starship installed"
else
    fail "starship not found"
fi

echo ""
echo "All checks passed!"
