# Dotfiles Makefile

.PHONY: help install backup clean test

# Default target
help:
	@echo "Available targets:"
	@echo "  install  - Install dotfiles (create symlinks)"
	@echo "  backup   - Backup existing dotfiles"
	@echo "  clean    - Remove symlinks (restore from backup)"
	@echo "  test     - Test shell configurations"
	@echo "  help     - Show this help message"

# Install dotfiles
install:
	@echo "Installing dotfiles..."
	@./install.sh

# Backup existing dotfiles
backup:
	@echo "Creating backup of existing dotfiles..."
	@mkdir -p ~/.dotfiles.backup
	@for file in .zshrc .bashrc .bash_profile .gitconfig .vimrc .tmux.conf; do \
		if [ -f "$$HOME/$$file" ] || [ -L "$$HOME/$$file" ]; then \
			echo "Backing up $$file"; \
			cp "$$HOME/$$file" "$$HOME/.dotfiles.backup/"; \
		fi; \
	done

# Clean installation (remove symlinks)
clean:
	@echo "Removing dotfiles symlinks..."
	@for file in .zshrc .bashrc .bash_profile .gitconfig .vimrc .tmux.conf; do \
		if [ -L "$$HOME/$$file" ]; then \
			echo "Removing symlink $$file"; \
			rm "$$HOME/$$file"; \
		fi; \
	done
	@echo "Restoring from backup if available..."
	@if [ -d "$$HOME/.dotfiles.backup" ]; then \
		cp $$HOME/.dotfiles.backup/* $$HOME/ 2>/dev/null || true; \
	fi

# Test shell configurations
test:
	@echo "Testing shell configurations..."
	@bash -n shell/bash/bashrc && echo "✓ bashrc syntax OK" || echo "✗ bashrc syntax error"
	@zsh -n shell/zsh/zshrc && echo "✓ zshrc syntax OK" || echo "✗ zshrc syntax error"
	@echo "Testing function loading..."
	@bash -c "source shell/common.sh && echo '✓ common.sh loaded successfully'" || echo "✗ common.sh failed to load"
