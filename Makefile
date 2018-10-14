FORCE=-i
REPO_PATH=$(HOME)/.dotfiles
LINK_PATH=$(HOME)
ZSH_CUSTOM=$(REPO_PATH)/zsh/custom

symlinks:
	# Make a copy of the sourcing file
	# Edit this individually for each host
	cp $(REPO_PATH)/sources $(LINK_PATH)/.sources
	echo "source $(LINK_PATH)/.sources" > $(LINK_PATH)/.bashrc
	ln -s $(FORCE) $(LINK_PATH)/.bashrc $(LINK_PATH)/.bash_profile

	# Make symlinks for non-bash configuration files
	ln -s $(FORCE) $(REPO_PATH)/vimrc $(LINK_PATH)/.vimrc
	ln -s $(FORCE) $(REPO_PATH)/screenrc $(LINK_PATH)/.screenrc
	ln -s $(FORCE) $(REPO_PATH)/gitconfig $(LINK_PATH)/.gitconfig
	ln -s $(FORCE) $(REPO_PATH)/tmux.conf $(LINK_PATH)/.tmux.conf
.PHONY: symlinks

machine-specific:
	touch $(REPO_PATH)/machine_specific_bashrc
.PHONY: machine-specific

vundle:
	mkdir -p $(REPO_PATH)/bundle
	if [ ! -d "$(REPO_PATH)/bundle/Vundle.vim" ] ; then \
		git clone https://github.com/VundleVim/Vundle.vim.git \
			$(REPO_PATH)/bundle/Vundle.vim ;\
	fi
.PHONY: vundle

vim-colorschemes:
	mkdir -p $(LINK_PATH)/.vim
	ln -s -h $(FORCE) $(REPO_PATH)/vim_colors $(LINK_PATH)/.vim/colors
.PHONY: vim-colorschemes

vim-plugins:
	vim +silent! +PluginInstall +qall
.PHONY: vim-plugins

powerline:
	pip install --user git+https://github.com/danielbalcells/powerline.git 
	ln -s $(FORCE) \
		$(shell pip show powerline-status | grep Location | awk '{print $$2}')/powerline/bindings/bash/powerline.sh \
		$(REPO_PATH)/powerline.sh
	mkdir -p $(LINK_PATH)/.config
	ln -s -h $(FORCE) $(REPO_PATH)/powerline_config_files $(LINK_PATH)/.config/powerline
.PHONY: powerline

oh-my-zsh:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
.PHONY: oh-my-zsh

zsh-symlink:
	ln -s $(FORCE) $(REPO_PATH)/zsh/zshrc $(LINK_PATH)/.zshrc
.PHONY: zsh-symlink

zsh-plugins:
	mkdir -p ./zsh/custom/themes
	mkdir -p ./zsh/custom/plugins
	./clone_if_not_exists.sh https://github.com/bhilburn/powerlevel9k.git $(ZSH_CUSTOM)/themes/powerlevel9k
	./clone_if_not_exists.sh https://github.com/zsh-users/zsh-autosuggestions $(ZSH_CUSTOM)/plugins/zsh-autosuggestions
	./clone_if_not_exists.sh https://github.com/zsh-users/zsh-syntax-highlighting.git $(ZSH_CUSTOM)/plugins/zsh-syntax-highlighting
.PHONY: zsh-plugins

zsh: oh-my-zsh zsh-symlink zsh-plugins

all: symlinks machine-specific vundle vim-colorschemes vim-plugins powerline
