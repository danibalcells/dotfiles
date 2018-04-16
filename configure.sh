#! /bin/bash
# Make aliases for .dotfiles
if [[ -z "$1" ]]; then force="-i"; else force=$1; fi
if [[ -z "$2" ]]; then repo_path=$HOME/.dotfiles; else repo_path=$2; fi
if [[ -z "$3" ]]; then link_path=$HOME; else link_path=$3; fi

# Make a copy of the sourcing file
# Edit this individually for each host
cp $repo_path/sources $link_path/.sources
echo "source $link_path/.sources" > $link_path/.bashrc
ln -s $force $link_path/.bashrc $link_path/.bash_profile

# Make symlinks for non-bash configuration files
ln -s $force $repo_path/vimrc $link_path/.vimrc
ln -s $force $repo_path/screenrc $link_path/.screenrc
ln -s $force $repo_path/gitconfig $link_path/.gitconfig
ln -s $force $repo_path/tmux.conf $link_path/.tmux.conf

# Create machine-specific file -to be ignored in repo- if it doesn't exist already
touch $repo_path/machine_specific_bashrc

# Source new stuff
source $link_path/.sources

#Install vim colorschemes
mkdir -p $link_path/.vim
ln -s -h $force $repo_path/vim_colors $link_path/.vim/colors

# Install Vundle
mkdir -p $repo_path/bundle
if [ ! -d "$repo_path/bundle/Vundle.vim" ] ; then
    git clone https://github.com/VundleVim/Vundle.vim.git \
        $repo_path/bundle/Vundle.vim
fi
vim +silent! +PluginInstall +qall

# Install Powerline
pip install --user git+https://github.com/danielbalcells/powerline.git 
powerline_path=$(pip show powerline-status | grep Location | awk '{print $2}')
powerline_bash=$powerline_path/powerline/bindings/bash/powerline.sh
ln -s $force $powerline_bash $repo_path/powerline.sh
mkdir -p $link_path/.config
ln -s -h $force $repo_path/powerline_config_files $link_path/.config/powerline
