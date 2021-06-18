# Terminal
declare -A terminal_args=(
  ['-C arg']='terminal cmd; DEFAULT: $TERMINAL_CMD'
  ['-X arg']='terminal exec flag; DEFAULT: $TERMINAL_EXEC_FLAG'
  ['-t arg']='terminal title'
  ['-T arg']='terminal title flag; DEFAULT: $TERMINAL_TITLE_FLAG'
  ['-w arg']='terminal workspace, moved by wmctrl, requires title arg; DEFAULT: $TERMINAL_DEFAULT_WORKSPACE'
  ['-p arg']='grid position; IN: fullscreen|left|right'
  ['-f arg']='fallback command; DEFAULT: exec $TERMINAL_FALLBACK_SHELL'
  ['-c arg']='cmd, needs to be a string'
); function terminal() {
  cmd=( ${_args["-C arg"]} ) # terminal cmd

  if [[ -n ${_args[-t arg]} && -n ${_args["-T arg"]} ]]; then
    cmd+=( ${_args["-T arg"]} "${_args[-t arg]}" )
  fi

  # exec flag + cmd
  cmd+=( ${_args["-X arg"]} /bin/bash -c "${_args[-c arg]}; ${_args["-f arg"]}" )

  # workspace, requires title
  if [[ -n ${_args["-w arg"]} && -n ${_args["-T arg"]} && -n ${_args["-t arg"]} ]]; then
    wmctrl_cmd=( wmctrl -r ${_args["-t arg"]} -t ${_args["-w arg"]} )
  fi

  "${cmd[@]}"
  sleep 2s
  "${wmctrl_cmd[@]}"
  _args_to orb utils position_window -- -tp
}



# declare -A terminal_title_args=(
#   ['1']='title of current terminal'
# ); function terminal_title() {
#   # Set terminal tab title. Usage: title "new tab name"
#   prefix=${PS1%%\\a*}                  # Everything before: \a
#   search=${prefix##*;}                 # Eeverything after: ;
#   esearch="${search//\\/\\\\}"         # Change \ to \\ in old title
#   export PS1="${PS1/$esearch/$@}"             # Search and replace old with new
# }
