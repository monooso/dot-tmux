#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Quickly navigate to any code directory, and create a tmux session
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

# tmux is not currently running, or we don't have the required session.
# Either way, create the session, but don't attach to it.
if [[ -z $tmux_running ]] || ! tmux has-session -t $selected_name 2> /dev/null; then
  # Open three windows: vim, shell, server
  tmux new-session -s $selected_name -c $selected -n vim -d
  tmux new-window -t $selected_name -c $selected -n shell
  tmux new-window -t $selected_name -c $selected -n server

  # Focus the vim window. We can't really launch it, because of nested git worktree directories.
  tmux select-window -t $selected_name:1
fi

# If we're *inside* tmux, switch to the session; otherwise attach to it.
if [[ -n $TMUX ]]; then
  tmux switch-client -t $selected_name
else
  tmux a -t $selected_name
fi
