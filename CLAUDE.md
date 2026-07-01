# Dotfiles

Shell dotfiles for macOS/Linux. Managed via symlinks — `install.sh` creates
`$HOME` symlinks pointing into this repo; no files are generated at install time.

## Commands

```bash
make install      # Symlink dotfiles into $HOME
make backup       # Non-destructive snapshot of current $HOME files (cp, not mv)
make clean        # Remove repo symlinks, restore from most recent backup
make test         # Run syntax checks + test suite
make test-syntax  # bash -n / zsh -n on all shell files
make test-suite   # Run tests/test-*.sh
```

## Architecture

```
symlinks.conf        # Manifest: repo source → $HOME target (shared by install.sh + Makefile)
shell/zsh/zshenv     # Entry point for zsh — resolves DOTFILES_DIR via :A symlink trick
shell/bash/bashrc    # Entry point for bash — sets DOTFILES_DIR, sources common.sh
shell/common.sh      # Platform detection, OTEL config, PATH, tool init, sources doppler+functions
shell/aliases.sh     # All shell aliases
shell/functions.sh   # All shell functions
shell/doppler-secrets.{sh,zsh}  # Secrets via Doppler (sourced from common.sh)
```

## Data Flow

See [`docs/DATA_FLOW.md`](docs/DATA_FLOW.md) for install-time symlinking, shell
startup, and runtime secret access. Conventions that follow from it are below.

## Key Conventions

- `DOTFILES_DIR` is self-resolving: zshenv derives it from the symlink target via
  `${${(%):-%x}:A}`; bashrc via `readlink`. Override with `DOTFILES_DIR=/path make install`.
- `symlinks.conf` is the single source of truth — edit it to add/remove managed files.
- `make backup` uses `cp -RP` (non-destructive); `install.sh backup_file` uses `mv -f`
  (destructive, to make room for symlinks). Both skip symlinks already pointing into repo.
- `make clean` only removes symlinks whose `readlink` resolves into `$DOTFILES_DIR` —
  safe to run on partially-installed systems.
- zsh-only secret helpers (`secret`, `doppler_export`) live in `shell/zsh/doppler-secrets.zsh`;
  bash gets only the cache/getter helpers from `shell/doppler-secrets.sh`.

## Testing

Tests live in `tests/test-*.sh`. Add new test files with that prefix; `make test-suite`
picks them up automatically. Syntax checks run first via `make test-syntax`.
