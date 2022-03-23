#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Quickly navigate to any code directory
# -----------------------------------------------------------------------------

# Find all of the "code" directories, and use FZF to fuzzy-find the desired one.
selected=$(find ~/bin ~/dotfiles ~/personal ~/work -maxdepth 1 -mindepth 1 -type d | fzf)

# If no directory was selected, we're done.
if [[ -z $selected ]]; then
  exit 0
fi

# Use the normalised basename of the selected directory as our session name.
selected_name=$(basename "$selected" | tr " -" "_" | tr "[:upper:]" "[:lower:]" | tr -cd "[:alnum:]_")
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
