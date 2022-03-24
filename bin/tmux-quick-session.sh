#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Quickly navigate to any code directory, and create a tmux session
# -----------------------------------------------------------------------------

dotfiles=$(find ~/dotfiles -maxdepth 1 -mindepth 1 -type d)
personal=$(find ~/personal -maxdepth 2 -mindepth 1 -type d)
work=$(find ~/work -maxdepth 2 -mindepth 1 -type d)

all_directories="${dotfiles}\n${personal}\n${work}"

# Use FZF to fuzzy-find the desired directory.
selected=$(echo "$all_directories" | fzf)

# If no directory was selected, we're done.
if [[ -z $selected ]]; then
  exit 0
fi

# Extract the last two segments of the selected directory, and normalise the
# string. This is our session name.
selected_name=$(
  echo "$(basename $(dirname "$selected"))_$(basename "$selected")" \
    | tr -d "[:space:]" \
    | tr "[:upper:]" "[:lower:]" \
    | tr -c "[:alnum:]" "_"
  )

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
