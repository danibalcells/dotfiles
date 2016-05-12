#! /bin/bash
# Make aliases for dotfiles
# This should be run from the dotfiles repo root directory

# Make a copy of the sourcing file
# Edit this individually for each host
cp ./sources ~/.bash_profile
ln -s -i ~/.bash_profile ~/.bash_aliases

# Make symlinks for non-bash configuration files
ln -s -i ./vimrc ~/.vimrc
ln -s -i ./screenrc ~/.screenrc
