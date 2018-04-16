export CLICOLOR=1
export PYTHON_DEFAULT_VERSION="anaconda2"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

export TERM=xterm-256color

function git_status_prompt(){
	git_status="$(git status 2>&1)"
	if [[ ! -z "$(echo $git_status | grep fatal)" ]]; then
		echo -e '$'
	elif [[ ! -z "$(echo $git_status | grep clean | grep ahead)" ]]; then
		echo -e '\033[0;33m$\033[0m'
	elif [[ ! -z "$(echo $git_status | grep clean)" ]]; then
		echo -e '\033[0;32m$\033[0m'
	else
		echo -e '\033[0;31m$\033[0m'
	fi
}


if [ "$color_prompt" = yes ]; then
	PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]$ '
else
    PS1='\u@\h:\W\$ '
fi
unset color_prompt force_color_prompt


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias lla='ls -lahtr'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# Set tab width
tabs 4

# Quick function to rename sessions in iTerm
function title {
    echo -ne "\033]0;"$*"\007"
}

# Function to start a screen session and rename iTerm window with the same name
function scr {
    name=$1
    # If there is already a session with this name, reattach
    existing_session=$(screen -ls \
        | grep -v 'No Sockets found'\
        | grep -v 'screens on'\
        | grep -v 'Sockets in'\
        | grep $name \
        | awk '{print $1}')
    if [ ! -z "$existing_session" ]; then
        title $name
        screen -dr $existing_session
    else
        title $name
        screen -S $name bash -c 'export ITERM_TITLE='$name'; bash -i'
    fi
}
if [ ! -z "$ITERM_TITLE" ]; then title $ITERM_TITLE; fi

# Alias for uploading a file to transfer.sh
transfer() { if [ $# -eq 0 ]; then echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; return 1; fi
tmpfile=$( mktemp -t transferXXX ); if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile; else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ; fi; cat $tmpfile; rm -f $tmpfile; }

# Use Powerline
if [ -d "$HOME/Library/Python/3.6/bin" ]; then
    PATH="$PATH:$HOME/Library/Python/3.6/bin"
fi
if [ -d "$HOME/Library/Python/2.7/bin" ]; then
    PATH="$PATH:$HOME/Library/Python/2.7/bin"
fi

if [[ ! -z $(which powerline-daemon) ]]; then
    powerline-daemon -q
    POWERLINE_BASH_CONTINUATION=1
    POWERLINE_BASH_SELECT=1
    . $HOME/.dotfiles/powerline.sh
fi
