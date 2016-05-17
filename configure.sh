#! /bin/bash
# Make aliases for .dotfiles
if [[ -z "$1" ]]; then repo_path=~/.dotfiles; else repo_path=$1; fi
if [[ -z "$2" ]]; then link_path=~; else link_path=$2; fi

# Make a copy of the sourcing file
# Edit this individually for each host
cp $repo_path/sources $link_path/.sources
echo "source $link_path/.sources" >> $link_path/.bashrc
ln -s -f $link_path/.bashrc $link_path/.bash_profile

# Make symlinks for non-bash configuration files
ln -s -f $repo_path/vimrc $link_path/.vimrc
ln -s -f $repo_path/screenrc $link_path/.screenrc
ln -s -f $repo_path/gitconfig $link_path/.gitconfig

# Source new stuff
source $link_path/.bashrc
