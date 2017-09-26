#! /bin/bash
# Make aliases for .dotfiles
if [[ -z "$1" ]]; then force="-i"; else force=$1; fi
if [[ -z "$2" ]]; then repo_path=~/.dotfiles; else repo_path=$2; fi
if [[ -z "$3" ]]; then link_path=~; else link_path=$3; fi

# Make a copy of the sourcing file
# Edit this individually for each host
cp $repo_path/sources $link_path/.sources
echo "source $link_path/.sources" >> $link_path/.bashrc
ln -s $force $link_path/.bashrc $link_path/.bash_profile

# Make symlinks for non-bash configuration files
ln -s $force $repo_path/vimrc $link_path/.vimrc
ln -s $force $repo_path/screenrc $link_path/.screenrc
ln -s $force $repo_path/gitconfig $link_path/.gitconfig

# Create machine-specific file -to be ignored in repo- if it doesn't exist already
touch $repo_path/machine_specific_bashrc

# Source new stuff
source $link_path/.sourcesc
