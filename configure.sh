#! /bin/bash
# Make aliases for .dotfiles
repo_path=~/.dotfiles


# Make a copy of the sourcing file
# Edit this individually for each host
cp $repo_path/sources ~/.bash_profile
ln -s -f ~/.bash_profile ~/.bashrc

# Make symlinks for non-bash configuration files
ln -s -f $repo_path/vimrc ~/.vimrc
ln -s -f $repo_path/screenrc ~/.screenrc
ln -s -f $repo_path/gitconfig ~/.gitconfig
