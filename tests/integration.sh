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

render_option() {
  local target="$1" option="$2"
  "${TMUX[@]}" display-message -t "$target" -p "$(get_option "$option")"
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

"${TMUX[@]}" set-option -t projects @seer_session_state working
"${TMUX[@]}" set-window-option -t projects:api @seer_window_state needs_input
"${TMUX[@]}" set-window-option -t projects:seer @seer_window_state working
"${TMUX[@]}" set-window-option -t projects:logs @seer_window_state neutral

assert_eq \
  '#[fg=#1a1b26,bg=#{?client_prefix,#e0af68,#{?#{==:#{@seer_session_state},needs_input},#565f89,#{?#{==:#{@seer_session_state},working},#9ece6a,#7aa2f7}}},bold] #{?client_prefix,●,○} #S ' \
  "$(get_option status-left)" \
  'default status-left'
assert_eq \
  '#[fg=#{?#{==:#{@seer_window_state},needs_input},#565f89,#{?#{==:#{@seer_window_state},working},#9ece6a,#a9b1d6}},bg=#1a1b26] #W ' \
  "$(get_option window-status-format)" \
  'inactive window'
assert_eq \
  '#[fg=#{?client_prefix,#e0af68,#{?#{==:#{@seer_window_state},needs_input},#565f89,#{?#{==:#{@seer_window_state},working},#9ece6a,#7aa2f7}}},bg=#2a2f41,bold] #W ' \
  "$(get_option window-status-current-format)" \
  'active window'
assert_eq '' "$(get_option window-status-separator)" 'window separator'
assert_eq '#{@seer_widget}' "$(get_option status-right)" 'default right side'
assert_eq 'bg=#1a1b26' "$(get_option status-style)" 'status style'
assert_eq 'fg=#9ece6a,bg=#2a2f41' "$(get_option mode-style)" 'mode style'
assert_eq 'fg=#2a2f41' "$(get_option pane-border-style)" 'pane border'
assert_eq 'fg=#7aa2f7' "$(get_option pane-active-border-style)" 'active pane border'

assert_eq '#[fg=#1a1b26,bg=#9ece6a,bold] ○ projects ' "$(render_option projects:api status-left)" 'session summarizes all windows'
assert_eq '#[fg=#565f89,bg=#2a2f41,bold] api ' "$(render_option projects:api window-status-current-format)" 'active waiting window'
assert_eq '#[fg=#9ece6a,bg=#1a1b26] seer ' "$(render_option projects:seer window-status-format)" 'inactive working window'
assert_eq '#[fg=#a9b1d6,bg=#1a1b26] logs ' "$(render_option projects:logs window-status-format)" 'inactive neutral window'
"${TMUX[@]}" set-window-option -t projects:logs @seer_window_state unexpected
assert_eq '#[fg=#a9b1d6,bg=#1a1b26] logs ' "$(render_option projects:logs window-status-format)" 'unknown window state is neutral'

for option in status-left status-right window-status-format window-status-current-format; do
  [[ "$(get_option "$option")" != *'#('* ]] || fail "$option contains a runtime command"
done

"${TMUX[@]}" set-option -g @recife_background '#101010'
"${TMUX[@]}" set-option -g @recife_surface '#202020'
"${TMUX[@]}" set-option -g @recife_foreground '#cccccc'
"${TMUX[@]}" set-option -g @recife_accent '#66aaff'
"${TMUX[@]}" set-option -g @recife_active '#77dd77'
"${TMUX[@]}" set-option -g @recife_alert '#ffcc66'
"${TMUX[@]}" set-option -g @recife_waiting '#888899'
"${TMUX[@]}" set-option -g @recife_status_right '#{session_name}'
run_theme

assert_eq \
  '#[fg=#101010,bg=#{?client_prefix,#ffcc66,#{?#{==:#{@seer_session_state},needs_input},#888899,#{?#{==:#{@seer_session_state},working},#77dd77,#66aaff}}},bold] #{?client_prefix,●,○} #S ' \
  "$(get_option status-left)" \
  'overridden status-left'
assert_eq \
  '#[fg=#{?#{==:#{@seer_window_state},needs_input},#888899,#{?#{==:#{@seer_window_state},working},#77dd77,#cccccc}},bg=#101010] #W ' \
  "$(get_option window-status-format)" \
  'overridden inactive window'
assert_eq \
  '#[fg=#{?client_prefix,#ffcc66,#{?#{==:#{@seer_window_state},needs_input},#888899,#{?#{==:#{@seer_window_state},working},#77dd77,#66aaff}}},bg=#202020,bold] #W ' \
  "$(get_option window-status-current-format)" \
  'overridden active window'
assert_eq '#{session_name} #{@seer_widget}' "$(get_option status-right)" 'custom right plus Seer'

"${TMUX[@]}" set-option -t projects @seer_session_state working
"${TMUX[@]}" set-window-option -t projects:api @seer_window_state needs_input
"${TMUX[@]}" set-window-option -t projects:seer @seer_window_state working
"${TMUX[@]}" set-window-option -t projects:logs @seer_window_state neutral
assert_eq '#[fg=#101010,bg=#77dd77,bold] ○ projects ' "$(render_option projects:api status-left)" 'custom session working'
assert_eq '#[fg=#888899,bg=#202020,bold] api ' "$(render_option projects:api window-status-current-format)" 'custom active waiting'
assert_eq '#[fg=#77dd77,bg=#101010] seer ' "$(render_option projects:seer window-status-format)" 'custom inactive working'
assert_eq '#[fg=#cccccc,bg=#101010] logs ' "$(render_option projects:logs window-status-format)" 'custom inactive neutral'

"${TMUX[@]}" set-option -g @recife_show_seer off
run_theme
assert_eq '#{session_name}' "$(get_option status-right)" 'disabled Seer slot'
assert_eq '#[fg=#101010,bg=#77dd77,bold] ○ projects ' "$(render_option projects:api status-left)" 'session accent works without square'

"${TMUX[@]}" set-option -g @recife_show_seer on
"${TMUX[@]}" set-option -g @recife_seer_accents off
run_theme
assert_eq '#{session_name} #{@seer_widget}' "$(get_option status-right)" 'square remains with accents disabled'
assert_eq '#[fg=#101010,bg=#66aaff,bold] ○ projects ' "$(render_option projects:api status-left)" 'disabled session accent'
assert_eq '#[fg=#66aaff,bg=#202020,bold] api ' "$(render_option projects:api window-status-current-format)" 'disabled active accent'
assert_eq '#[fg=#cccccc,bg=#101010] seer ' "$(render_option projects:seer window-status-format)" 'disabled inactive accent'

"${TMUX[@]}" set-option -g @recife_seer_accents on
"${TMUX[@]}" set-option -g @recife_status_right '#(sleep 20)'
run_theme
assert_eq '#{@seer_widget}' "$(get_option status-right)" 'dynamic custom format rejected'
[[ "$(get_option status-right)" != *'#('* ]] || fail 'rejected command reached status-right'

before="$("${TMUX[@]}" show-options -g)"
run_theme
after="$("${TMUX[@]}" show-options -g)"
assert_eq "$before" "$after" 'idempotent reload'

printf 'integration checks passed\n'
