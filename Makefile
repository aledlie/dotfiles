# Dotfiles Makefile

.PHONY: help install backup clean test test-syntax test-suite

# Files install.sh symlinks into $HOME (keep in sync with create_symlink calls)
DOTFILES := .zshrc .zprofile .prompt.zsh .bashrc .bash_profile .prompt.bash \
            .dircolors .gitconfig .vimrc .tmux.conf

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

# Backup existing dotfiles (matches install.sh timestamped layout)
backup:
	@echo "Creating backup of existing dotfiles..."
	@dest="$$HOME/.dotfiles.backup/$$(date +%Y%m%dT%H%M%S)"; \
	for file in $(DOTFILES); do \
		if [ -e "$$HOME/$$file" ] || [ -L "$$HOME/$$file" ]; then \
			mkdir -p "$$dest"; \
			echo "Backing up $$file"; \
			cp -RP "$$HOME/$$file" "$$dest/"; \
		fi; \
	done; \
	if [ -d "$$dest" ]; then echo "Backup created at $$dest"; else echo "Nothing to back up"; fi

# Clean installation (remove symlinks)
clean:
	@echo "Removing dotfiles symlinks..."
	@for file in $(DOTFILES); do \
		if [ -L "$$HOME/$$file" ]; then \
			echo "Removing symlink $$file"; \
			rm "$$HOME/$$file"; \
		fi; \
	done
	@echo "Restoring from most recent backup if available..."
	@latest=$$(ls -1d "$$HOME"/.dotfiles.backup/*/ 2>/dev/null | sort | tail -n1); \
	latest=$${latest%/}; \
	if [ -n "$$latest" ] && [ -d "$$latest" ]; then \
		echo "Restoring from $$latest"; \
		cp -Rp "$$latest/." "$$HOME/" 2>/dev/null || true; \
	else \
		echo "No backup found"; \
	fi
	@echo "Note: ~/.zshenv is not a symlink; remove the install.sh-appended block manually if desired"

# Test shell configurations
test: test-syntax test-suite

test-syntax:
	@echo "=== Syntax checks ==="
	@failed=0; \
	bash -n shell/bash/bashrc && echo "  ✓ bashrc" || { echo "  ✗ bashrc"; failed=1; }; \
	bash -n shell/common.sh && echo "  ✓ common.sh" || { echo "  ✗ common.sh"; failed=1; }; \
	bash -n shell/functions.sh && echo "  ✓ functions.sh" || { echo "  ✗ functions.sh"; failed=1; }; \
	bash -n shell/aliases.sh && echo "  ✓ aliases.sh" || { echo "  ✗ aliases.sh"; failed=1; }; \
	if command -v zsh >/dev/null 2>&1; then \
		zsh -n shell/zsh/zshrc && echo "  ✓ zshrc" || { echo "  ✗ zshrc"; failed=1; }; \
	else \
		echo "  - zshrc (skipped: zsh not installed)"; \
	fi; \
	exit $$failed

test-suite:
	@echo ""
	@if ! ls tests/test-*.sh >/dev/null 2>&1; then \
		echo "  No test files found in tests/"; exit 0; \
	fi; \
	for t in tests/test-*.sh; do \
		echo "--- Running $$t ---"; \
		bash "$$t" || exit 1; \
		echo ""; \
	done
