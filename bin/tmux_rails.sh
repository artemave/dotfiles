#!/bin/sh

tmux start-server

project_name=$(basename `pwd`)

if ! $(tmux has-session -t $project_name) && [ -f ./config/routes.rb ]; then
  tmux new-session -d -s $project_name -n shell
  tmux new-window -t $project_name:2 -n vim
  tmux new-window -t $project_name:3 -n zeus #'zeus start'
  tmux new-window -t $project_name:4 -n server
  tmux new-window -t $project_name:5 -n console
  tmux new-window -t $project_name:6 -n logs

  tmux select-window -t $project_name:1
fi

#tmux -u attach-session -t $project_name
