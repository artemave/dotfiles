#!/bin/sh

tmux start-server

project_name=$(basename `pwd`)

if [ ! $(tmux has-session -t $project_name) ] && [ -f ./config/routes.rb ]; then
  tmux new-session -d -s $project_name -n shell

  tmux new-window -t $project_name:2 -n vim vim
  tmux new-window -t $project_name:3 -n console 'rails c'
  tmux split-window -t $project_name:3 -h 'rails db'
  tmux new-window -t $project_name:4 -n server-log 'rails s'
  tmux split-window -t $project_name:4 'tail -f log/development.log'

  tmux select-window -t $project_name:1
fi

tmux -u attach-session -t $project_name
