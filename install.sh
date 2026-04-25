#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_root="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
dry_run=0

if [[ "${1-}" == "--dry-run" ]]; then
  dry_run=1
fi

backup_created=0

log() {
  printf '%s\n' "$*"
}

run() {
  if (( dry_run )); then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

ensure_backup_dir() {
  if (( backup_created == 0 )); then
    run mkdir -p "$backup_root"
    backup_created=1
  fi
}

link_file() {
  local rel_path="$1"
  local source_path="$repo_root/$rel_path"
  local target_path="$HOME/$rel_path"
  local target_dir backup_path backup_dir
  target_dir="$(dirname "$target_path")"
  backup_path="$backup_root/$rel_path"
  backup_dir="$(dirname "$backup_path")"

  if [[ -L "$target_path" ]] && [[ "$(readlink "$target_path")" == "$source_path" ]]; then
    log "ok: $rel_path"
    return
  fi

  if [[ -e "$target_path" ]] || [[ -L "$target_path" ]]; then
    ensure_backup_dir
    run mkdir -p "$backup_dir"
    run mv "$target_path" "$backup_path"
    log "backup: $rel_path -> $backup_path"
  fi

  run mkdir -p "$target_dir"
  run ln -s "$source_path" "$target_path"
  log "linked: $rel_path"
}

while IFS= read -r rel_path; do
  case "$rel_path" in
    .config/*|.gitignore|.zshrc)
      link_file "$rel_path"
      ;;
  esac
done < <(git -C "$repo_root" ls-files)

if (( dry_run )); then
  log "dry run complete"
elif (( backup_created )); then
  log "backups saved to $backup_root"
fi
