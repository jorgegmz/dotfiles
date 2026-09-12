#!/bin/sh
# Claude Code status line
#   line 1:  [Model] 📁 dir | 🌿 branch
#   line 2:  ████░░░░ NN% | $C.CC | ⏱ Xm Ys          (context window | session cost | elapsed)
#   line 3:  ████░░░░ NN% · resets Xh Ym · 7d NN%     (Claude usage: 5h session | reset | weekly)
#
# Line 3 reads Claude Code's built-in rate_limits from stdin: five_hour.used_percentage
# is the real 5-hour session usage (matches claude.ai), seven_day is the weekly window.
# Present only for Pro/Max accounts after the first API response; the segment is omitted
# otherwise. No external tools or caching needed.
PATH="$HOME/.bun/bin:/opt/homebrew/bin:/usr/bin:/bin:$PATH"
input=$(cat)

# --- account label (which Claude account this session is signed in as) ---
# Read live from oauthAccount.emailAddress in the active config dir's .claude.json
# (CLAUDE_CONFIG_DIR when set by an account switcher, else the default ~/.claude.json)
# so it always matches whatever `/status` reports, instead of a value that drifts
# stale after switching accounts.
ACCOUNT_JSON="${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json"
ACCOUNT=$(jq -r '.oauthAccount.emailAddress // empty' "$ACCOUNT_JSON" 2>/dev/null)

# --- colors (real ESC byte, so we can print with %s) ---
ESC=$(printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
CYAN="${ESC}[36m"
GREEN="${ESC}[92m"
GRAY="${ESC}[90m"

# --- 10-cell progress bar: $1 = pct (0..100) -> colored cells, no % text ---
make_bar() {
  p=$1
  [ "$p" -gt 100 ] && p=100
  [ "$p" -lt 0 ] && p=0
  f=$(( p / 10 ))
  e=$(( 10 - f ))
  cells=""; i=0; while [ "$i" -lt "$f" ]; do cells="${cells}█"; i=$(( i + 1 )); done
  head="${GREEN}${cells}${RESET}${GRAY}"
  cells=""; i=0; while [ "$i" -lt "$e" ]; do cells="${cells}░"; i=$(( i + 1 )); done
  printf '%s%s%s' "$head" "$cells" "$RESET"
}

# --- parse fields (graceful fallbacks) ---
model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
model=$(printf '%s' "$model" | sed 's/^Claude //')        # "Claude Opus 4" -> "Opus 4"

# reasoning effort (present only when the model supports it, e.g. "max")
effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')

dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir_name=$(basename "$dir" 2>/dev/null)
[ -z "$dir_name" ] && dir_name="?"

used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // 0')
dur_ms=$(printf '%s' "$input" | jq -r '.cost.total_duration_ms // 0')

# --- git branch (omit segment if not a repo) ---
branch=""
[ -n "$dir" ] && branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)

# --- format session cost ---
cost_fmt=$(printf '$%.2f' "$cost" 2>/dev/null) || cost_fmt='$0.00'

# --- format elapsed time ---
dur_ms=$(printf '%.0f' "$dur_ms" 2>/dev/null) || dur_ms=0
total_s=$(( dur_ms / 1000 ))
h=$(( total_s / 3600 ))
m=$(( (total_s % 3600) / 60 ))
s=$(( total_s % 60 ))
if [ "$h" -gt 0 ]; then
  time_fmt="${h}h ${m}m"
elif [ "$m" -gt 0 ]; then
  time_fmt="${m}m ${s}s"
else
  time_fmt="${s}s"
fi

# --- line 1: model (+ effort), dir, branch, account ---
model_label="${model}"
[ -n "$effort" ] && model_label="${model} ${GRAY}·${RESET}${BOLD}${CYAN} ${effort}"
line1="${BOLD}${CYAN}[${model_label}]${RESET} 📁 ${dir_name}"
[ -n "$branch" ] && line1="${line1} ${GRAY}|${RESET} 🌿 ${branch}"
[ -n "$ACCOUNT" ] && line1="${line1} ${GRAY}|${RESET} 👤 ${ACCOUNT}"

# --- line 2: context bar, session cost, elapsed ---
line2=""
if [ -n "$used_pct" ]; then
  pct=$(printf '%.0f' "$used_pct")
  line2="$(make_bar "$pct") ${pct}% ${GRAY}|${RESET} "
fi
line2="${line2}${GREEN}${cost_fmt}${RESET} ${GRAY}|${RESET} ⏱ ${time_fmt}"

# --- line 3: Claude's built-in 5-hour & weekly usage (rate_limits, Pro/Max only) ---
line3=""
p5=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$p5" ]; then
  p5=$(printf '%.0f' "$p5")
  reset5=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
  p7=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

  line3="$(make_bar "$p5") ${p5}%"

  if [ -n "$reset5" ]; then
    rem=$(( reset5 - $(date +%s) ))
    [ "$rem" -lt 0 ] && rem=0
    rh=$(( rem / 3600 ))
    rm=$(( (rem % 3600) / 60 ))
    if [ "$rh" -gt 0 ]; then
      reset_fmt="${rh}h ${rm}m"
    elif [ "$rm" -gt 0 ]; then
      reset_fmt="${rm}m"
    else
      reset_fmt="<1m"
    fi
    line3="${line3} ${GRAY}·${RESET} resets ${reset_fmt}"
  fi

  if [ -n "$p7" ]; then
    p7=$(printf '%.0f' "$p7")
    line3="${line3} ${GRAY}·${RESET} 7d ${p7}%"
  fi
fi

# --- emit (2 or 3 lines) ---
out="${line1}
${line2}"
[ -n "$line3" ] && out="${out}
${line3}"
printf '%s' "$out"
