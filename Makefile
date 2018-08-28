FORCE=-i
REPO_PATH=$(HOME)/.dotfiles
LINK_PATH=$(HOME)

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

all: symlinks machine-specific vundle vim-colorschemes vim-plugins powerline
