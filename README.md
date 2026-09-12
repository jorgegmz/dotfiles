# dotfiles

Personal dev-environment config, applied automatically to every Ona environment.

## Contents
- `.vimrc` — vim config (uses vim-plug)
- `statusline-command.sh` — Claude Code status line renderer
- `install.sh` — installs vim + vim-plug + plugins, `jq`, and wires the status line
  into `~/.claude/settings.json` (merged, so the SiegePal baseline is preserved)

## Use with Ona
Point Ona at this repo once (per user, applies to every environment):
```bash
ona user dotfiles set --repository https://github.com/<you>/dotfiles
```
On each env start Ona clones this to `~/.dotfiles` and runs `install.sh`.

## Note on the status line
`install.sh` merges the `statusLine` key into `~/.claude/settings.json`. Depending on
whether the dotfiles install runs before or after the SiegePal `claude-setup`, you may
occasionally need to re-run it once so the key sticks:
```bash
bash ~/.dotfiles/install.sh
```
