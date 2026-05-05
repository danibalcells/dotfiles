function watermelogin() {
    local_status=$(ping -c 1 -W 1 watermelon.local &> /dev/null ; echo $?)
    if [[ "$local_status" -ne "0" ]]; then
        ssh -p 2233 themissingwatermelon.com
    else
        ssh -p 2233 watermelon.local
    fi
}

function gitclonehere() {
    git init
    git remote add origin "$1"
}

# Local tmux in iTerm -CC integration mode (attach existing or create).
# Usage: tm [session]   — session defaults to "main"
function tm() {
    local session="${1:-main}"
    tmux -CC new-session -AD -s "$session"
}

# Remote tmux in iTerm -CC integration mode over SSH.
# Usage: tmr <host> [session]   — session defaults to "main"
function tmr() {
    if [[ -z "$1" ]]; then
        echo "usage: tmr <host> [session]" >&2
        return 1
    fi
    local host="$1" session="${2:-main}"
    ssh "$host" -t "tmux -CC new-session -A -s '$session'"
}

# New tmux window in the current session with a given name.
# Usage: tw <name>
function tw() {
    if [[ -z "$1" ]]; then
        echo "usage: tw <window-name>" >&2
        return 1
    fi
    tmux new-window -n "$1"
}

# Rename the current window and session to the same name.
function tt() {
    tmux rename-window "$1"
    tmux rename-session "$1"
}

# Rename the current window only.
function trw() {
    tmux rename-window "$1"
}

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

if [[ "$(uname)" == "Darwin" ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias lla='ls -lahtr'

alias grep='grep --color=auto'

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
