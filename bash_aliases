#! /bin/bash

# Log in to watermelon
#alias watermelogin="ssh -p 2233 themissingwatermelon.com"
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
	git remote add origin $1
}

alias tm="tmux new-session -AD -s"
