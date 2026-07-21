#!/usr/bin/env bash
set -euo pipefail

separator="__recife_$$_${RANDOM}__"
values="$(tmux display-message -p "#{@recife_background}${separator}#{@recife_surface}${separator}#{@recife_foreground}${separator}#{@recife_accent}${separator}#{@recife_active}${separator}#{@recife_alert}${separator}#{@recife_status_right}${separator}#{@recife_show_seer}")"
background="${values%%"$separator"*}"
values="${values#*"$separator"}"
surface="${values%%"$separator"*}"
values="${values#*"$separator"}"
foreground="${values%%"$separator"*}"
values="${values#*"$separator"}"
accent="${values%%"$separator"*}"
values="${values#*"$separator"}"
active="${values%%"$separator"*}"
values="${values#*"$separator"}"
alert="${values%%"$separator"*}"
values="${values#*"$separator"}"
custom_right="${values%%"$separator"*}"
show_seer="${values#*"$separator"}"

background="${background:-#1a1b26}"
surface="${surface:-#2a2f41}"
foreground="${foreground:-#a9b1d6}"
accent="${accent:-#7aa2f7}"
active="${active:-#9ece6a}"
alert="${alert:-#e0af68}"
show_seer="${show_seer:-on}"

if [[ "$custom_right" == *'#('* ]]; then
  tmux display-message 'Recife: @recife_status_right cannot contain #() commands'
  custom_right=''
fi

seer_enabled=true
case "$show_seer" in
  0 | off | OFF | false | FALSE | no | NO) seer_enabled=false ;;
esac

status_right="$custom_right"
if $seer_enabled; then
  if [[ -n "$status_right" ]]; then
    status_right+=' '
  fi
  status_right+='#{@seer_widget}'
fi

status_left="#[fg=$background,bg=#{?client_prefix,$alert,$accent},bold] #{?client_prefix,●,○} #S "
window_status="#[fg=$foreground,bg=$background] #W "
window_current="#[fg=$active,bg=$surface,bold] #W "

tmux \
  set-option -g status-left-length 80 \; \
  set-option -g status-right-length 80 \; \
  set-option -g status-style "bg=$background" \; \
  set-option -g status-left "$status_left" \; \
  set-option -g status-right "$status_right" \; \
  set-option -g window-status-format "$window_status" \; \
  set-option -g window-status-current-format "$window_current" \; \
  set-option -g window-status-separator '' \; \
  set-option -g mode-style "fg=$active,bg=$surface" \; \
  set-option -g message-style "fg=$background,bg=$accent" \; \
  set-option -g message-command-style "fg=$foreground,bg=$surface" \; \
  set-option -g pane-border-style "fg=$surface" \; \
  set-option -g pane-active-border-style "fg=$accent" \; \
  set-option -g pane-border-status off
