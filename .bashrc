# checkwinsize keeps terminal columns correct after resize
shopt -s checkwinsize

# colored prompt: green user@host, blue cwd
PS1="\[\033[01;32m\]\u@\h \[\033[01;34m\]\w \$ \[\033[00m\]"

# xterm title bar
case $TERM in
    xterm*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
        ;;
esac

alias ll='ls -lah --color=auto'
alias l='ls -lh --color=auto'
log_command() {
  local exit_code=$?
  local cmd
  cmd=$(history 1 | sed 's/^ *[0-9]* *//')
  local escaped_cmd="${cmd//"'"/"''"}"
  sqlite3 /root/.bash_history.db \
    "INSERT INTO history (ts, cwd, cmd, exit_code, host) \
     VALUES (datetime('now'), '$PWD', '$escaped_cmd', $exit_code, '$HOSTNAME');"
}
PROMPT_COMMAND="log_command"
