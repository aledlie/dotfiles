# Dotfiles Makefile

.PHONY: help install backup clean test test-syntax test-suite

# Absolute path to this repo (matches install.sh's DOTFILES_DIR resolution).
# Used to tell repo symlinks apart from real files during backup/clean.
# ?= honors a DOTFILES_DIR override from the environment, just like install.sh's
# ${DOTFILES_DIR:-...}; otherwise realpath (a GNU make builtin, not the shell
# command) resolves symlinks to match install.sh's `pwd -P`, keeping the
# repo-symlink case-matches stable.
DOTFILES_DIR ?= $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# Files install.sh symlinks into $HOME — the $HOME target column of the shared
# symlinks.conf manifest (single source of truth, also read by install.sh).
DOTFILES := $(shell awk 'NF && $$1 !~ /^\#/ {print $$2}' $(DOTFILES_DIR)/symlinks.conf)

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

# Backup existing dotfiles (matches install.sh timestamped layout).
# Skips symlinks that already point into the repo: those have no original
# worth saving, and snapshotting them would make `clean` restore them.
backup:
	@echo "Creating backup of existing dotfiles..."
	@dest="$$HOME/.dotfiles.backup/$$(date +%Y%m%dT%H%M%S)-$$$$"; \
	for file in $(DOTFILES); do \
		target="$$HOME/$$file"; \
		{ [ -e "$$target" ] || [ -L "$$target" ]; } || continue; \
		case "$$(readlink "$$target" 2>/dev/null)" in \
			"$(DOTFILES_DIR)"/*) echo "Skipping $$file (symlink into repo)"; continue ;; \
		esac; \
		mkdir -p "$$dest"; \
		echo "Backing up $$file"; \
		cp -RP "$$target" "$$dest/"; \
	done; \
	if [ -d "$$dest" ]; then echo "Backup created at $$dest"; else echo "Nothing to back up"; fi

# Clean installation: remove repo symlinks, then restore originals.
# Only removes symlinks that point into the repo (never real files), and
# restores per-file — only files this repo manages, only when absent in $HOME,
# never re-creating a repo symlink captured in an older backup.
clean:
	@echo "Removing dotfiles symlinks..."
	@for file in $(DOTFILES); do \
		target="$$HOME/$$file"; \
		[ -L "$$target" ] || continue; \
		case "$$(readlink "$$target" 2>/dev/null)" in \
			"$(DOTFILES_DIR)"/*) echo "Removing symlink $$file"; rm "$$target" ;; \
			*) echo "Leaving $$file (not a repo symlink)" ;; \
		esac; \
	done
	@echo "Restoring from most recent backup if available..."
	@latest=$$(ls -1d "$$HOME"/.dotfiles.backup/*/ 2>/dev/null | sort | tail -n1); \
	latest=$${latest%/}; \
	if [ -z "$$latest" ] || [ ! -d "$$latest" ]; then echo "No backup found"; exit 0; fi; \
	echo "Restoring from $$latest"; \
	for file in $(DOTFILES); do \
		src="$$latest/$$file"; \
		{ [ -e "$$src" ] || [ -L "$$src" ]; } || continue; \
		case "$$(readlink "$$src" 2>/dev/null)" in \
			"$(DOTFILES_DIR)"/*) echo "Skipping $$file (backup is a repo symlink)"; continue ;; \
		esac; \
		if [ -e "$$HOME/$$file" ] || [ -L "$$HOME/$$file" ]; then \
			echo "Skipping $$file (already present)"; continue; \
		fi; \
		echo "Restoring $$file"; \
		cp -RP "$$src" "$$HOME/$$file"; \
	done

# Test shell configurations
test: test-syntax test-suite

test-syntax:
	@echo "=== Syntax checks ==="
	@failed=0; \
	bash -n shell/bash/bashrc && echo "  ✓ bashrc" || { echo "  ✗ bashrc"; failed=1; }; \
	bash -n shell/bash/bash_profile && echo "  ✓ bash_profile" || { echo "  ✗ bash_profile"; failed=1; }; \
	bash -n shell/common.sh && echo "  ✓ common.sh" || { echo "  ✗ common.sh"; failed=1; }; \
	bash -n shell/functions.sh && echo "  ✓ functions.sh" || { echo "  ✗ functions.sh"; failed=1; }; \
	bash -n shell/aliases.sh && echo "  ✓ aliases.sh" || { echo "  ✗ aliases.sh"; failed=1; }; \
	if command -v zsh >/dev/null 2>&1; then \
		zsh -n shell/zsh/zshenv && echo "  ✓ zshenv" || { echo "  ✗ zshenv"; failed=1; }; \
		zsh -n shell/zsh/zprofile && echo "  ✓ zprofile" || { echo "  ✗ zprofile"; failed=1; }; \
		zsh -n shell/zsh/zshrc && echo "  ✓ zshrc" || { echo "  ✗ zshrc"; failed=1; }; \
	else \
		echo "  - zshenv/zprofile/zshrc (skipped: zsh not installed)"; \
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
