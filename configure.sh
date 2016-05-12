#! /bin/bash
# Make aliases for .dotfiles

# Make a copy of the sourcing file
# Edit this individually for each host
cp ~/.dotfiles/sources ~/.bash_profile
ln -s -i ~/.bash_profile ~/.bash_aliases

# Make symlinks for non-bash configuration files
ln -s -i ~/.dotfiles/vimrc ~/.vimrc
ln -s -i ~/.dotfiles/screenrc ~/.screenrc
