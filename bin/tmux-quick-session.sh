#!/bin/bash

# Quickly navigate to any code directory
selected=$(find ~/bin ~/dotfiles ~/personal ~/work -maxdepth 1 -mindepth 1 -type d | fzf)

if [[ -z $selected ]]; then
  exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# $TMUX is set if we're inside a tmux session
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
  tmux new-session -s $selected_name -c $selected
  exit 0
fi

if ! tmux has-session -t $selected_name 2> /dev/null; then
  tmux new-session -ds $selected_name -c $selected
fi

if [[ -z $TMUX ]]; then
  tmux a -t $selected_name
else
  tmux switch-client -t $selected_name
fi
