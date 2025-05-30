# Tmux

# Attaches tmux to a session
alias ta='tmux attach -t'
# Creates a new session
alias tn='tmux new-session -s'
# Kill a session
alias tk='tmux kill-session -t'
# Lists all ongoing sessions
alias tl='tmux list-sessions'
# Switches to a session
alias ts='tmux switch -t'

alias cuda='echo $CUDA_VISIBLE_DEVICES'
alias ll='ls -alF'

tt(){
  SESSION_NAME_="main"
  CONTAINER_NAME_="torch"

  tmux start-server

  if ! tmux has-session -t main 2>/dev/null; then
      tmux new-session -d -s $SESSION_NAME_ -x "$(tput cols)" -y "$(tput lines)"
      # window 1
      tmux rename-window -t $SESSION_NAME_:0 'info'
      tmux send-keys -t $SESSION_NAME_:info 'htop' C-m

      # window 2
      tmux new-window -t $SESSION_NAME_:1 -n "torch"
      tmux split-window -v -l 40% -t $SESSION_NAME_:torch
      tmux select-pane -U
      tmux split-window -v -l 50% -t $SESSION_NAME_:torch
      tmux select-pane -U
      tmux split-window -v -l 50% -t $SESSION_NAME_:torch
      tmux select-pane -D
      tmux split-window -v -l 50% -t $SESSION_NAME_:torch
      tmux select-pane -U
      tmux select-pane -U
      tmux select-pane -U

      tmux send-keys -t $SESSION_NAME_:torch 'export CUDA_VISIBLE_DEVICES=0 && clear' C-m
      tmux select-pane -D
      tmux send-keys -t $SESSION_NAME_:torch 'export CUDA_VISIBLE_DEVICES=1 && clear' C-m
      tmux select-pane -D
      tmux send-keys -t $SESSION_NAME_:torch 'export CUDA_VISIBLE_DEVICES=2 && clear' C-m
      tmux select-pane -D
      tmux send-keys -t $SESSION_NAME_:torch 'export CUDA_VISIBLE_DEVICES=3 && clear' C-m
      tmux select-pane -D
      tmux send-keys -t $SESSION_NAME_:torch 'nvitop' C-m

      # window 3
      tmux new-window -t $SESSION_NAME_:2 -n "playground"

  else
      tmux attach -t $SESSION_NAME_
  fi
}


