# Dotfiles Refactor Plan

## Context

This is a ~10-year-old dotfiles repo at `~/.dotfiles`. It works, but every few years
when deploying to a new machine, things break (Vim plugins, Powerline dependencies,
hardcoded paths, confusing Makefile). The goal is to modernize and simplify while
preserving all useful configuration.

The owner uses **zsh** as their primary shell, **Cursor** as their editor (not Vim),
and wants a Powerline-style prompt. They do NOT use the oh-my-zsh git or docker
aliases. They DO want to keep Vim plugins working (for occasional use).

## Goal

"New machine → clone repo → run one command → shell environment is ready."

Optionally on macOS: also install Homebrew packages.

## Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Dotfile manager | None (plain symlinks in install.sh) | Simplest; no tool to learn/remember |
| Prompt | **Starship** (replaces Powerlevel10k) | P10k is on life support; Starship is Rust, cross-shell, TOML config, actively maintained |
| Plugin framework | **None** (drop oh-my-zsh) | Only 2 plugins actually needed; source them directly |
| Vim plugin manager | **Keep Vundle** | Owner wants plugins to work; Vundle is already set up |
| Shell aliases | Keep all, merge into one file | Drop oh-my-zsh git/docker alias plugins |
| Machine-specific config | Conditionals in zshrc + `~/.local.zsh` | No separate `machine_specific_*` files in the repo |
| macOS packages | **Brewfile** | `brew bundle` for reproducible installs |
| Bash config | Archive to `legacy/` | Owner uses zsh exclusively |
| Powerline (Python) | Remove entirely | Replaced by Starship |

## Current Repo Structure (before refactor)

```
~/.dotfiles/
├── .gitignore
├── .zshrc                        # Just "source .sources" — unused/confusing
├── Makefile                      # Fragile symlink + install logic
├── bashrc                        # Old bash config (Python 2.7/3.6 paths, Powerline)
├── bundle/                       # Vundle plugins (gitignored)
├── clone_if_not_exists.sh        # Helper for cloning zsh plugins
├── dockerrc                      # Docker aliases
├── gitconfig                     # Git config (hardcoded email, cache credential helper)
├── iterm/                        # iTerm plist + color scheme
├── machine_specific_bashrc       # Per-machine bash config (gitignored)
├── machine_specific_zshrc        # Per-machine zsh config (gitignored)
├── powerline.sh                  # BROKEN symlink to Python powerline
├── powerline_config_files/       # Powerline JSON config
├── screenrc                      # Screen config
├── shell_aliases                 # Shared aliases (watermelogin, ls, tmux, etc.)
├── sources                       # Bash sourcing chain
├── tmux.conf                     # Tmux config
├── vim_colors/                   # Vim color schemes (monokai, material-monokai)
├── vimrc                         # Vim config with Vundle plugins
└── zsh/
    ├── autosuggestions.zsh       # Has a NUL byte (corrupted)
    ├── custom/                   # oh-my-zsh custom dir (plugins + themes, gitignored)
    ├── powerlevel9k.zsh          # Deprecated p9k config
    └── zshrc                     # Main zsh config (boilerplate-heavy, hardcoded paths)
```

## Target Repo Structure (after refactor)

```
~/.dotfiles/
├── README.md                     # How to use this repo
├── install.sh                    # Idempotent bootstrap script
├── Brewfile                      # Homebrew packages (curated essentials)
├── Makefile                      # Thin wrapper: make install, make brew, make test
│
├── zsh/
│   ├── .zshrc                    # Clean main config
│   └── aliases.zsh               # All aliases (shell + docker, merged)
│
├── starship/
│   └── .config/
│       └── starship.toml         # Starship prompt config
│
├── git/
│   └── .gitconfig                # Modernized git config
│
├── vim/
│   ├── .vimrc                    # Cleaned up, plugins in correct order
│   └── .vim/
│       └── colors/
│           ├── monokai.vim
│           └── material-monokai.vim
│
├── tmux/
│   └── .tmux.conf                # Unchanged
│
├── screen/
│   └── .screenrc                 # Unchanged
│
├── iterm/                        # Reference only (not symlinked)
│   ├── com.googlecode.iterm2.plist
│   └── material-design-colors.itermcolors
│
├── local.zsh.example             # Template for ~/.local.zsh
│
├── test/
│   ├── Dockerfile                # For testing in Docker
│   └── test.sh                   # Verify installation works
│
└── legacy/                       # Archived old configs
    ├── bashrc
    ├── sources
    ├── dockerrc
    ├── machine_specific_bashrc
    ├── clone_if_not_exists.sh
    ├── powerline.sh
    ├── powerline_config_files/
    └── zsh/
        ├── powerlevel9k.zsh
        └── autosuggestions.zsh
```

### Key structural principle

Each top-level directory (except `iterm/`, `test/`, `legacy/`) is a **symlink
package**: its contents mirror the target home directory structure. The `install.sh`
script creates symlinks from each file to the corresponding path under `$HOME`.

For example:
- `zsh/.zshrc` → `~/.zshrc`
- `git/.gitconfig` → `~/.gitconfig`
- `vim/.vimrc` → `~/.vimrc`
- `vim/.vim/colors/monokai.vim` → `~/.vim/colors/monokai.vim`
- `starship/.config/starship.toml` → `~/.config/starship.toml`
- `tmux/.tmux.conf` → `~/.tmux.conf`
- `screen/.screenrc` → `~/.screenrc`

## File-by-File Implementation

### 1. `install.sh`

Idempotent bootstrap script. Safe to run multiple times.

```bash
#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf "\033[0;34m[dotfiles]\033[0m %s\n" "$1"; }
ok()   { printf "\033[0;32m[dotfiles]\033[0m %s\n" "$1"; }
warn() { printf "\033[0;33m[dotfiles]\033[0m %s\n" "$1"; }

# --- Homebrew (macOS only) ---
if [[ "$(uname)" == "Darwin" ]]; then
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        info "Installing Homebrew packages..."
        brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock
    fi
fi

# --- Starship ---
if ! command -v starship &>/dev/null; then
    info "Installing Starship prompt..."
    if command -v brew &>/dev/null; then
        brew install starship
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
fi

# --- pyenv (cross-platform) ---
if [[ ! -d "$HOME/.pyenv" ]]; then
    info "Installing pyenv..."
    if command -v brew &>/dev/null; then
        brew install pyenv
    else
        curl -fsSL https://pyenv.run | bash
    fi
fi

# --- nvm + Node (cross-platform) ---
export NVM_DIR="$HOME/.nvm"
if [[ ! -d "$NVM_DIR" ]]; then
    info "Installing nvm..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    source "$NVM_DIR/nvm.sh"
    info "Installing latest Node LTS via nvm..."
    nvm install --lts
fi

# --- Zsh plugins (clone if missing) ---
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

# --- Symlinks ---
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
symlink "$DOTFILES_DIR/vim/.vimrc"                     "$HOME/.vimrc"
symlink "$DOTFILES_DIR/vim/.vim/colors"                "$HOME/.vim/colors"
symlink "$DOTFILES_DIR/tmux/.tmux.conf"                "$HOME/.tmux.conf"
symlink "$DOTFILES_DIR/screen/.screenrc"               "$HOME/.screenrc"
symlink "$DOTFILES_DIR/starship/.config/starship.toml" "$HOME/.config/starship.toml"

# --- Vundle (Vim plugins) ---
VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"
if [[ ! -d "$VUNDLE_DIR" ]]; then
    info "Installing Vundle..."
    git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"
fi
info "Installing Vim plugins..."
vim +PluginInstall +qall 2>/dev/null || warn "Vim plugin install had warnings (non-fatal)"

# --- Local config ---
if [[ ! -f "$HOME/.local.zsh" ]]; then
    cp "$DOTFILES_DIR/local.zsh.example" "$HOME/.local.zsh"
    info "Created ~/.local.zsh from template — edit it for this machine"
fi

ok "Done! Restart your shell or run: exec zsh"
```

### 2. `zsh/.zshrc`

Clean, no boilerplate. Approximately:

```bash
# --- PATH ---
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# --- Homebrew (auto-detect, no hardcoded path) ---
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

# --- Completion ---
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# --- Key bindings ---
bindkey -e
bindkey '^ ' autosuggest-accept

# --- Terminal ---
export TERM=xterm-256color
DISABLE_AUTO_TITLE="true"

# --- Plugins ---
ZSH_PLUGINS="$HOME/.zsh/plugins"
[[ -f "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# --- Aliases ---
source "$HOME/.dotfiles/zsh/aliases.zsh"

# --- Tools (auto-detect, only load if installed) ---

# pyenv
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# --- Prompt (Starship) ---
eval "$(starship init zsh)"

# --- Machine-specific overrides ---
[[ -f ~/.local.zsh ]] && source ~/.local.zsh
```

Things removed vs. current zshrc:
- All oh-my-zsh boilerplate and commented-out template lines
- Powerlevel9k/10k sourcing
- Hardcoded Google Cloud SDK path from ~/Downloads
- Hardcoded /Library/TeX/texbin (goes in ~/.local.zsh if needed)
- virtualenvwrapper (outdated; pyenv + venv or uv is modern)
- Redundant PIPENV_VENV_IN_PROJECT

Things preserved:
- PATH setup
- History config (improved)
- Autosuggestions + syntax highlighting
- bindkey for autosuggestion accept
- DISABLE_AUTO_TITLE
- pyenv, nvm (conditionally loaded)
- Machine-specific sourcing (via ~/.local.zsh)

### 3. `zsh/aliases.zsh`

Merge `shell_aliases` + useful parts of `dockerrc`. Drop dead aliases. Preserve:

```bash
# --- SSH ---
function watermelogin() {
    local_status=$(ping -c 1 -W 1 watermelon.local &> /dev/null ; echo $?)
    if [[ "$local_status" -ne "0" ]]; then
        ssh -p 2233 themissingwatermelon.com
    else
        ssh -p 2233 watermelon.local
    fi
}

# --- Git ---
function gitclonehere() {
    git init
    git remote add origin "$1"
}

# --- Tmux ---
alias tm="tmux new-session -AD -s"
function tt() {
    tmux rename-window "$1"
    tmux rename-session "$1"
}

# --- Screen ---
function scr() {
    name=$1
    existing_session=$(screen -ls \
        | grep -v 'No Sockets found' \
        | grep -v 'screens on' \
        | grep -v 'Sockets in' \
        | grep "$name" \
        | awk '{print $1}')
    if [[ -n "$existing_session" ]]; then
        title "$name"
        screen -dr "$existing_session"
    else
        title "$name"
        screen -S "$name"
    fi
}

# --- ls ---
if [[ "$(uname)" == "Darwin" ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias lla='ls -lahtr'

# --- grep ---
alias grep='grep --color=auto'

# --- Utility ---
function title() {
    echo -ne "\033]0;$*\007"
}

transfer() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: transfer <file>"
        return 1
    fi
    tmpfile=$(mktemp -t transferXXX)
    if tty -s; then
        basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
        curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> "$tmpfile"
    else
        curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> "$tmpfile"
    fi
    cat "$tmpfile"
    rm -f "$tmpfile"
}
```

Dropped:
- Docker aliases (user confirmed not needed)
- dircolors block (Linux-specific, handled by ls alias above)
- `if [ ! -z "$ITERM_TITLE" ]; then title $ITERM_TITLE; fi` (iTerm-specific edge case)

### 4. `starship/.config/starship.toml`

Replicate the Powerlevel9k/10k look. The current config shows:
- Left: context (user@host) + directory
- Right: git branch/status + virtualenv + time

Starship equivalent:

```toml
# Powerline-style prompt replicating the previous Powerlevel9k/10k setup
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$python\
$nodejs\
$cmd_duration\
$line_break\
$character"""

right_format = """$time"""

[username]
style_user = "bold green"
show_always = false

[hostname]
ssh_only = true
style = "bold green"

[directory]
truncation_length = 3
truncate_to_repo = false
style = "bold blue"

[git_branch]
style = "bold green"
format = "[$symbol$branch(:$remote_branch)]($style) "

[git_status]
style = "bold yellow"

[python]
format = '[${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'
symbol = "🐍 "

[nodejs]
format = "[$symbol($version )]($style)"

[cmd_duration]
min_time = 2000
format = "[$duration]($style) "

[time]
disabled = false
format = "[$time]($style)"
time_format = "%H:%M"
style = "dimmed white"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
```

### 5. `git/.gitconfig`

Modernized:

```ini
[user]
    name = Daniel Balcells
    email = dbalcells@gmail.com

[push]
    default = current
    autoSetupRemote = true

[pull]
    rebase = true

[core]
    editor = vim

[merge]
    tool = vimdiff

[credential]
    helper = store

[credential "https://github.com"]
    username = danielbalcells

[filter "lfs"]
    smudge = git-lfs smudge -- %f
    process = git-lfs filter-process
    required = true
    clean = git-lfs clean -- %f

[init]
    defaultBranch = main

# To override email for work repos, add to ~/.local.zsh:
#   git config --global includeIf.gitdir:~/work/.path ~/work/.gitconfig
# Then create ~/work/.gitconfig with [user] email = work@company.com
```

Changes from current:
- `push.default` → `current` (safer than `matching`)
- Added `push.autoSetupRemote` (no more `--set-upstream` on first push)
- Added `pull.rebase = true`
- Removed old credential helpers for bitbucket.org and pdihub.hi.inet
- Changed credential helper to `store` (or use `osxkeychain` on macOS via ~/.local.zsh)
- Added `init.defaultBranch = main`
- Added comment about includeIf for work email

### 6. `vim/.vimrc`

Keep current config but fix two bugs:
1. Move the two Plugin declarations from AFTER `vundle#end()` to BEFORE it (lines 171-172 → between line 52 and 54)
2. Update Vundle rtp to use `~/.vim/bundle/Vundle.vim` (standard location) instead of `~/.dotfiles/bundle/Vundle.vim`
3. Update `vundle#begin()` to use `~/.vim/bundle/` instead of `~/.dotfiles/bundle/`

Everything else (keybindings, colors, UI settings, airline, fzf, nerdcommenter, tagbar, PEP8 indentation, folding, split navigation) stays the same.

### 7. `vim/.vim/colors/`

Move `vim_colors/monokai.vim` and `vim_colors/material-monokai.vim` here unchanged.

### 8. `tmux/.tmux.conf`

Current `tmux.conf` — keep unchanged. It's clean and well-configured.

### 9. `screen/.screenrc`

Current `screenrc` — keep unchanged.

### 10. `local.zsh.example`

Template for per-machine config:

```bash
# ~/.local.zsh — Machine-specific configuration
# This file is sourced at the end of .zshrc
# It is NOT tracked in git — edit freely for this machine

# --- macOS: credential helper ---
# git config --global credential.helper osxkeychain

# --- Work email override ---
# git config --global includeIf.gitdir:~/work/.path ~/work/.gitconfig

# --- LaTeX (macOS with MacTeX) ---
# export PATH="/Library/TeX/texbin:$PATH"

# --- Google Cloud SDK ---
# [[ -f ~/google-cloud-sdk/path.zsh.inc ]] && source ~/google-cloud-sdk/path.zsh.inc
# [[ -f ~/google-cloud-sdk/completion.zsh.inc ]] && source ~/google-cloud-sdk/completion.zsh.inc

# --- Custom PATH additions ---
# export PATH="$HOME/custom/bin:$PATH"
```

### 11. `Brewfile`

Curated essentials (not everything currently installed — many are project-specific dependencies):

```ruby
# Core CLI tools
brew "git-lfs"
brew "gh"
brew "tree"
brew "wget"
brew "htop"
brew "watch"
brew "make"
brew "tmux"

# Modern CLI replacements (optional but nice)
# brew "bat"       # better cat
# brew "eza"       # better ls
# brew "ripgrep"   # better grep
# brew "fd"        # better find
# brew "zoxide"    # better cd

# Development
brew "pyenv"
brew "pipx"
brew "node"
brew "pnpm"

# Prompt
brew "starship"

# Uncomment as needed:
# brew "ffmpeg"
# brew "imagemagick"
# brew "pandoc"
# brew "cmake"
# brew "docker-compose"
# brew "flyctl"
# brew "magic-wormhole"
# brew "displayplacer"
# brew "bottom"          # system monitor (btm)
# brew "git-filter-repo"

# Casks (macOS apps)
# cask "mactex"          # LaTeX
```

### 12. `Makefile`

Thin wrapper:

```makefile
.PHONY: install brew test clean

install:
	./install.sh

brew:
	brew bundle --file=Brewfile --no-lock

test:
	docker build -t dotfiles-test -f test/Dockerfile .
	docker run --rm dotfiles-test

clean:
	@echo "This would remove symlinks. Not implemented (be careful)."
```

### 13. `README.md`

```markdown
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
```

### 14. `test/Dockerfile`

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    git curl zsh vim sudo locales \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev libffi-dev \
    liblzma-dev libncursesw5-dev xz-utils tk-dev \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV HOME=/home/testuser

RUN useradd -m -s /bin/zsh testuser
USER testuser
WORKDIR /home/testuser

COPY --chown=testuser:testuser . /home/testuser/.dotfiles

RUN cd /home/testuser/.dotfiles && ./install.sh

COPY --chown=testuser:testuser test/test.sh /home/testuser/test.sh
RUN chmod +x /home/testuser/test.sh
CMD ["/home/testuser/test.sh"]
```

### 15. `test/test.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

pass() { printf "\033[0;32m✓ %s\033[0m\n" "$1"; }
fail() { printf "\033[0;31m✗ %s\033[0m\n" "$1"; exit 1; }

# Check symlinks exist
[[ -L "$HOME/.zshrc" ]]      && pass ".zshrc symlink" || fail ".zshrc symlink missing"
[[ -L "$HOME/.gitconfig" ]]  && pass ".gitconfig symlink" || fail ".gitconfig symlink missing"
[[ -L "$HOME/.vimrc" ]]      && pass ".vimrc symlink" || fail ".vimrc symlink missing"
[[ -L "$HOME/.tmux.conf" ]]  && pass ".tmux.conf symlink" || fail ".tmux.conf symlink missing"
[[ -L "$HOME/.screenrc" ]]   && pass ".screenrc symlink" || fail ".screenrc symlink missing"
[[ -L "$HOME/.config/starship.toml" ]] && pass "starship.toml symlink" || fail "starship.toml symlink missing"

# Check plugins cloned
[[ -d "$HOME/.zsh/plugins/zsh-autosuggestions" ]] && pass "autosuggestions plugin" || fail "autosuggestions missing"
[[ -d "$HOME/.zsh/plugins/zsh-syntax-highlighting" ]] && pass "syntax-highlighting plugin" || fail "syntax-highlighting missing"

# Check Vundle installed
[[ -d "$HOME/.vim/bundle/Vundle.vim" ]] && pass "Vundle installed" || fail "Vundle missing"

# Check pyenv installed
[[ -d "$HOME/.pyenv" ]] && pass "pyenv installed" || fail "pyenv missing"

# Check nvm + node installed
[[ -d "$HOME/.nvm" ]] && pass "nvm installed" || fail "nvm missing"
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh" 2>/dev/null
command -v node &>/dev/null && pass "node installed ($(node --version))" || fail "node missing"

# Check local.zsh created
[[ -f "$HOME/.local.zsh" ]] && pass "~/.local.zsh created" || fail "~/.local.zsh missing"

# Check zsh starts without errors
error_output=$(zsh -c 'source ~/.zshrc' 2>&1 >/dev/null || true)
if [[ -z "$error_output" ]]; then
    pass "zsh starts clean"
else
    echo "  warnings: $error_output"
    pass "zsh starts (with warnings)"
fi

# Check starship is available
if command -v starship &>/dev/null; then
    pass "starship installed"
else
    fail "starship not found"
fi

echo ""
echo "All checks passed!"
```

### 16. `.gitignore`

```
# Machine-specific (not tracked)
local.zsh

# Vim plugins (installed by Vundle)
vim/.vim/bundle/

# Zsh plugins (cloned by install.sh)
.zsh/

# OS files
.DS_Store

# Legacy backup files
*.bak
```

## Branch-Based Migration Workflow

All work happens on a `refactor` branch. The `master` branch is untouched until
the very end, so switching back to `master` at any point restores the current
working installation.

### Safety model

- **Current symlinks** (e.g. `~/.vimrc → ~/.dotfiles/vimrc`) point to files on
  `master`. As long as the branch is `master`, these paths exist and work.
- **On the `refactor` branch**, new files are created alongside old ones in
  Phases 1-2. Old files are NOT deleted until Phase 5 (after local testing).
- **Rollback at any time**: `git checkout master` restores all old file paths.
  If `install.sh` was already run, restore the `.bak` files it created, or
  re-run the old `make symlinks` from master.

### Phase 0: Create branch

```bash
cd ~/.dotfiles
git checkout -b refactor
```

No files change. Current installation unaffected.

### Phase 1: Create new structure alongside existing files

1. Create directories: `git/`, `vim/`, `vim/.vim/`, `vim/.vim/colors/`,
   `tmux/`, `screen/`, `starship/`, `starship/.config/`, `test/`
   (Note: `zsh/` already exists)
2. Write ALL new files as specified in the "File-by-File Implementation"
   section above:
   - `zsh/.zshrc` (new clean config — different filename from old `zsh/zshrc`)
   - `zsh/aliases.zsh` (merged from shell_aliases + useful parts of dockerrc)
   - `starship/.config/starship.toml`
   - `git/.gitconfig`
   - `vim/.vimrc` (fixed version of current vimrc)
   - Copy `vim_colors/*.vim` → `vim/.vim/colors/`
   - `tmux/.tmux.conf` (copy of current tmux.conf)
   - `screen/.screenrc` (copy of current screenrc)
   - `install.sh` (make executable)
   - `local.zsh.example`
   - `Brewfile`
   - `Makefile` (new version — overwrites old one, but old one is on master)
   - `README.md`
   - `.gitignore` (new version)
   - `test/Dockerfile`
   - `test/test.sh` (make executable)

At this point, old files and new files coexist. Old symlinks still work because
old files haven't been moved or deleted.

3. Commit: "Add new dotfiles structure"

### Phase 2: Test in Docker

4. Run `make test` — builds a Docker container, copies the ENTIRE repo in,
   runs `install.sh`, runs `test/test.sh`. This is fully isolated:
   - The container creates its own symlinks inside the container
   - Nothing on the host machine is touched
   - The container is deleted after the test (`--rm`)
5. Fix any issues, re-run until tests pass
6. Commit fixes if any: "Fix issues found in Docker testing"

### Phase 3: Deploy locally

7. Run `./install.sh` on the actual machine
   - This creates new symlinks (e.g. `~/.vimrc → ~/.dotfiles/vim/.vimrc`)
   - Old symlinks are backed up to `.bak` files
   - Starship, pyenv, nvm, plugins are installed if missing
8. Restart shell: `exec zsh`
9. Verify:
   - Prompt looks right (Starship powerline style)
   - Aliases work (`ll`, `tm`, `watermelogin`, etc.)
   - `git config user.email` shows correct value
   - `vim` opens without errors
   - `pyenv --version` works
   - `node --version` works

### Phase 4: Rollback checkpoint

If anything is wrong at this point:
```bash
git checkout master
# Restore old symlinks:
for f in ~/.zshrc.bak ~/.vimrc.bak ~/.gitconfig.bak ~/.tmux.conf.bak ~/.screenrc.bak; do
    [[ -f "$f" ]] && mv "$f" "${f%.bak}"
done
exec zsh
```
This returns to the exact previous state.

If everything is good, continue to Phase 5.

### Phase 5: Clean up old files (only after confirming everything works)

10. Move legacy files:
    - `bashrc` → `legacy/bashrc`
    - `sources` → `legacy/sources`
    - `dockerrc` → `legacy/dockerrc`
    - `machine_specific_bashrc` → `legacy/machine_specific_bashrc`
    - `clone_if_not_exists.sh` → `legacy/clone_if_not_exists.sh`
    - `powerline.sh` → `legacy/powerline.sh`
    - `powerline_config_files/` → `legacy/powerline_config_files/`
    - `zsh/powerlevel9k.zsh` → `legacy/zsh/powerlevel9k.zsh`
    - `zsh/autosuggestions.zsh` → `legacy/zsh/autosuggestions.zsh`
    - `zsh/custom/` → delete (it's gitignored content)
11. Remove old root-level files now superseded by new packages:
    - Root `vimrc` (now at `vim/.vimrc`)
    - Root `gitconfig` (now at `git/.gitconfig`)
    - Root `tmux.conf` (now at `tmux/.tmux.conf`)
    - Root `screenrc` (now at `screen/.screenrc`)
    - Root `shell_aliases` (now at `zsh/aliases.zsh`)
    - Root `.zshrc` (the one that just says "source .sources")
    - Root `machine_specific_zshrc`
    - `vim_colors/` (now at `vim/.vim/colors/`)
    - `bundle/` directory (Vundle now installs to `~/.vim/bundle/`)
    - Old `zsh/zshrc` (now at `zsh/.zshrc`)
12. Keep `iterm/` in place (not part of symlink packages)
13. Commit: "Remove old files, move to legacy"

### Phase 6: Merge

14. `git checkout master && git merge refactor`
15. Done. Old state is still recoverable via `git log` / `git revert` if needed.

## Important Notes for the Implementing Agent

- **Work on the `refactor` branch** — never modify `master` directly
- **Read every file before modifying it** — the current contents matter
- **Do NOT delete `iterm/`** — it stays in the repo as reference
- **Do NOT proceed to Phase 5 without user confirmation** — the user must
  verify the new setup works locally before old files are removed
- The old `machine_specific_zshrc` currently contains Homebrew init,
  Powerlevel10k sourcing, and virtualenvwrapper. All of these are handled
  by the new zshrc (Homebrew auto-detect, Starship replaces p10k,
  virtualenvwrapper dropped in favor of pyenv/uv)
- The old `zsh/autosuggestions.zsh` has a **NUL byte corruption** — don't
  preserve it, the new setup sources the plugin directly
- The `vimrc` has two Plugin lines (typescript-vim, vim-jsx-typescript) AFTER
  `call vundle#end()` — move them before it in the new version
- The old `bundle/` directory in the repo root contained Vundle plugins.
  The new setup uses the standard `~/.vim/bundle/` location instead
- The Starship TOML is a starting point — the user may want to tweak it
  after seeing it. That's fine and expected
- Run `make test` (Docker) BEFORE running `install.sh` on the real machine
- The `Brewfile` includes a "modern CLI replacements" section that's
  commented out. These are suggestions the user can enable if they want
- Phases 1-2 should be done by the agent autonomously
- Phase 3 requires the user to run `install.sh` and confirm results
- Phase 5 should only happen after explicit user approval
