#!/bin/sh

tmux start-server

project_name=$(basename `pwd`)

if ! $(tmux has-session -t $project_name) && [ -f ./config/routes.rb ]; then
  tmux new-session -d -s $project_name -n shell
  tmux set-option -t $project_name set-remain-on-exit on

  tmux new-window -t $project_name:2 -n vim vim
  tmux new-window -t $project_name:3 -n console 'bundle exec rails c'
  tmux split-window -t $project_name:3 'bundle exec rails db -p'
  tmux new-window -t $project_name:4 -n server-log 'bundle exec rails s'
  tmux split-window -t $project_name:4 'tail -f ./log/development.log'

  tmux select-window -t $project_name:1
fi

tmux -u attach-session -t $project_name
