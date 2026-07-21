#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOCKET="recife-test-$$"
TMUX=(tmux -L "$SOCKET" -f /dev/null)

cleanup() {
  "${TMUX[@]}" kill-server 2>/dev/null || true
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_eq() {
  local expected="$1" actual="$2" label="$3"
  [[ "$actual" == "$expected" ]] || fail "$label: expected [$expected], got [$actual]"
}

get_option() {
  "${TMUX[@]}" show-options -gqv "$1"
}

"${TMUX[@]}" new-session -d -s projects -n api
"${TMUX[@]}" new-window -d -t projects -n seer
"${TMUX[@]}" new-window -d -t projects -n logs
SOCKET_PATH="$("${TMUX[@]}" display-message -p '#{socket_path}')"
SERVER_PID="$("${TMUX[@]}" display-message -p '#{pid}')"

run_theme() {
  TMUX="$SOCKET_PATH,$SERVER_PID,0" "$ROOT/recife.tmux"
}

run_theme

assert_eq \
  '#[fg=#1a1b26,bg=#{?client_prefix,#e0af68,#7aa2f7},bold] #{?client_prefix,●,○} #S ' \
  "$(get_option status-left)" \
  'default status-left'
assert_eq '#[fg=#a9b1d6,bg=#1a1b26] #W ' "$(get_option window-status-format)" 'inactive window'
assert_eq '#[fg=#9ece6a,bg=#2a2f41,bold] #W ' "$(get_option window-status-current-format)" 'active window'
assert_eq '' "$(get_option window-status-separator)" 'window separator'
assert_eq '#{@seer_widget}' "$(get_option status-right)" 'default right side'
assert_eq 'bg=#1a1b26' "$(get_option status-style)" 'status style'
assert_eq 'fg=#9ece6a,bg=#2a2f41' "$(get_option mode-style)" 'mode style'
assert_eq 'fg=#2a2f41' "$(get_option pane-border-style)" 'pane border'
assert_eq 'fg=#7aa2f7' "$(get_option pane-active-border-style)" 'active pane border'

for option in status-left status-right window-status-format window-status-current-format; do
  [[ "$(get_option "$option")" != *'#('* ]] || fail "$option contains a runtime command"
done

printf 'integration checks passed\n'
