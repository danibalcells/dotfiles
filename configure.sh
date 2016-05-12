#! /bin/bash
# Make aliases for .dotfiles
repo_path=~/.dotfiles


# Make a copy of the sourcing file
# Edit this individually for each host
cp $repo_path/sources ~/.bash_profile
ln -s -i ~/.bash_profile ~/.bash_aliases

# Make symlinks for non-bash configuration files
ln -s -i $repo_path/vimrc ~/.vimrc
ln -s -i $repo_path/screenrc ~/.screenrc
ln -s -i $repo_path/gitconfig ~/.gitconfig
