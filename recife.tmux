#!/usr/bin/env bash
set -euo pipefail

background='#1a1b26'
surface='#2a2f41'
foreground='#a9b1d6'
accent='#7aa2f7'
active='#9ece6a'
alert='#e0af68'

status_left="#[fg=$background,bg=#{?client_prefix,$alert,$accent},bold] #{?client_prefix,●,○} #S "
window_status="#[fg=$foreground,bg=$background] #W "
window_current="#[fg=$active,bg=$surface,bold] #W "

tmux \
  set-option -g status-left-length 80 \; \
  set-option -g status-right-length 80 \; \
  set-option -g status-style "bg=$background" \; \
  set-option -g status-left "$status_left" \; \
  set-option -g status-right '#{@seer_widget}' \; \
  set-option -g window-status-format "$window_status" \; \
  set-option -g window-status-current-format "$window_current" \; \
  set-option -g window-status-separator '' \; \
  set-option -g mode-style "fg=$active,bg=$surface" \; \
  set-option -g message-style "fg=$background,bg=$accent" \; \
  set-option -g message-command-style "fg=$foreground,bg=$surface" \; \
  set-option -g pane-border-style "fg=$surface" \; \
  set-option -g pane-active-border-style "fg=$accent" \; \
  set-option -g pane-border-status off
