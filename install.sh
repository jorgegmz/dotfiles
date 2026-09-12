#!/usr/bin/env bash
# Personal dotfiles installer.
#
# Ona clones this repo to ~/.dotfiles on env start and runs this script. It's also
# safe to run by hand: `bash ~/.dotfiles/install.sh`. Idempotent.
set -euo pipefail
DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log() { echo "[dotfiles] $*"; }

# --- vim + vim-plug + plugins ------------------------------------------------
log "linking .vimrc"
ln -sf "$DOT/.vimrc" "$HOME/.vimrc"

if ! command -v vim >/dev/null 2>&1; then
  log "installing vim"
  sudo apt-get update -qq && sudo apt-get install -y vim >/dev/null 2>&1 || true
fi

if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  log "installing vim-plug"
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
log "installing vim plugins (:PlugInstall)"
vim +PlugInstall +qall >/dev/null 2>&1 || true

# --- Claude Code status line -------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
  log "installing jq (status line dependency)"
  sudo apt-get update -qq && sudo apt-get install -y jq >/dev/null 2>&1 || true
fi

log "installing Claude status line"
mkdir -p "$HOME/.claude"
cp "$DOT/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
chmod +x "$HOME/.claude/statusline-command.sh"

# Merge the statusLine key into ~/.claude/settings.json WITHOUT clobbering the
# SiegePal baseline (hooks/permissions installed by claude-setup). If settings.json
# doesn't exist yet, create a minimal one; claude-setup merges its baseline on top.
SETTINGS="$HOME/.claude/settings.json"
CMD="sh $HOME/.claude/statusline-command.sh"
if command -v jq >/dev/null 2>&1; then
  if [ -f "$SETTINGS" ]; then
    tmp="$(mktemp)"
    jq --arg cmd "$CMD" '.statusLine = {type:"command", command:$cmd}' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  else
    jq -n --arg cmd "$CMD" '{statusLine:{type:"command", command:$cmd}}' > "$SETTINGS"
  fi
  log "statusLine merged into $SETTINGS"
fi

log "done"
