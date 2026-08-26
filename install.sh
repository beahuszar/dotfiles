#!/usr/bin/env bash
# Idempotent dotfiles installer. Safe to re-run on the same machine.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

backup_if_needed() {
  local target="$1"
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    echo "Backing up existing $target -> ${target}.backup.${TIMESTAMP}"
    mv "$target" "${target}.backup.${TIMESTAMP}"
  fi
}

link_file() {
  local source="$1"
  local target="$2"
  backup_if_needed "$target"
  ln -s "$source" "$target"
  echo "Linked $target -> $source"
}

ensure_line_in_file() {
  local marker="$1"
  local line="$2"
  local file="$3"
  touch "$file"
  if ! grep -qF "$marker" "$file"; then
    {
      echo ""
      echo "$marker"
      echo "$line"
    } >> "$file"
    echo "Added dotfiles hook to $file"
  else
    echo "$file already wired up, skipping"
  fi
}

ensure_git_include() {
  local include_path="$1"
  if ! git config --global --get-all include.path 2>/dev/null | grep -qxF "$include_path"; then
    git config --global --add include.path "$include_path"
    echo "Added include.path=$include_path to ~/.gitconfig"
  else
    echo "~/.gitconfig already includes $include_path, skipping"
  fi
}

# Safe to symlink outright — nothing else writes to these files.
link_file "${DOTFILES_DIR}/zshrc" "${HOME}/.zshrc"
link_file "${DOTFILES_DIR}/bash_aliases" "${HOME}/.bash_aliases"
link_file "${DOTFILES_DIR}/gitconfig-personal" "${HOME}/.gitconfig-personal"
link_file "${DOTFILES_DIR}/inputrc" "${HOME}/.inputrc"

# .bashrc is never symlinked — provisioning scripts append to the real file
# directly (session banners, env exports). Source our extras from it instead.
ensure_line_in_file \
  "# BEGIN dotfiles hook" \
  "[ -f \"${DOTFILES_DIR}/bashrc_extra\" ] && source \"${DOTFILES_DIR}/bashrc_extra\"" \
  "${HOME}/.bashrc"

# .gitconfig is never symlinked either — `git config --global` writes into
# the real file directly (user.name/user.email). Use git's own include
# mechanism to pull in our aliases/settings instead.
ensure_git_include "${DOTFILES_DIR}/gitconfig"

echo "Dotfiles setup complete."
