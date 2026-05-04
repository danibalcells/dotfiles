export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

bindkey -e
bindkey '^ ' autosuggest-accept

export TERM=xterm-256color
export COLORTERM=truecolor
export LANG=${LANG:-en_US.UTF-8}
DISABLE_AUTO_TITLE="true"

ZSH_PLUGINS="$HOME/.zsh/plugins"
[[ -f "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

source "$HOME/.dotfiles/zsh/aliases.zsh"

# Load dircolors on Linux (macOS ls -G uses LSCOLORS and ignores this)
if [[ "$(uname)" != "Darwin" ]] && command -v dircolors &>/dev/null; then
    [[ -f ~/.dircolors ]] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

_starship_set_palette() {
    local mode
    mode=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
    [[ "$mode" == "$_STARSHIP_LAST_MODE" ]] && return
    _STARSHIP_LAST_MODE="$mode"
    local palette="p10k_${(L)mode}"
    sed "s/^palette = .*/palette = \"$palette\"/" \
        "$HOME/.dotfiles/starship/.config/starship.toml" \
        > "${TMPDIR:-/tmp}/starship_active.toml"
    export STARSHIP_CONFIG="${TMPDIR:-/tmp}/starship_active.toml"
}
precmd_functions+=(_starship_set_palette)

eval "$(starship init zsh)"

# Long-running command bell
# Set ZBELL_DISABLE=1 in ~/.local.zsh (or anywhere in your environment) to silence it.
autoload -Uz add-zsh-hook
typeset -i ZBELL_THRESHOLD=${ZBELL_THRESHOLD:-20}

_zbell_save_start() { _zbell_start=$SECONDS }
_zbell_check() {
  [[ ${ZBELL_DISABLE:-0} == 1 ]] && return
  (( SECONDS - _zbell_start >= ZBELL_THRESHOLD )) && print "\a"
}

add-zsh-hook preexec _zbell_save_start
add-zsh-hook precmd  _zbell_check

[[ -f ~/.local.zsh ]] && source ~/.local.zsh
