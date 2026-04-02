.PHONY: install brew test clean

install:
	./install.sh

brew:
	brew bundle --file=Brewfile --no-lock

test:
	docker build -t dotfiles-test -f test/Dockerfile .
	docker run --rm dotfiles-test

clean:
	@echo "This would remove symlinks. Not implemented (be careful)."
