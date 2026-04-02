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

alias tm="tmux new-session -AD -s"

function tt() {
    tmux rename-window "$1"
    tmux rename-session "$1"
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
