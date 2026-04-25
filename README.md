# Dotfiles

Normal dotfiles repo. Home files are symlinked to this directory.

## Install

```bash
./install.sh
```

Preview only:

```bash
./install.sh --dry-run
```

## Commit

```bash
git status
git diff
git add -p
git commit -m "update dotfiles"
```

Only commit portable config. Keep secrets and machine-specific values in local ignored files.
