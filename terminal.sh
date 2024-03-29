# Terminal
declare -A terminal_args=(
  ['-C arg']='terminal cmd; DEFAULT: $ORB_TERMINAL_CMD'
  ['-x arg']='terminal exec shell; DEFAULT: $ORB_TERMINAL_EXEC_SHELL'
  ['-X arg']='terminal exec flag; DEFAULT: $ORB_TERMINAL_EXEC_FLAG'
  ['-T arg']='terminal title flag; DEFAULT: $ORB_TERMINAL_TITLE_FLAG'
  ['-t arg']='terminal title'
  ['-p arg']='terminal grid position; IN: fullscreen|left|right'
  ['-w arg']='terminal workspace, moved by wmctrl, requires title arg; DEFAULT: $ORB_TERMINAL_DEFAULT_WORKSPACE'
  ['-f arg']='terminal fallback command after exit; DEFAULT: $ORB_TERMINAL_FALLBACK_CMD'
  ['-F arg']='terminal fallback command after exit with title; DEFAULT: $ORB_TERMINAL_FALLBACK_CMD_TITLED'
  ['-- *']='cmd, interpreted as single string'
); function terminal() {
  local cmd=( ${_args["-C arg"]} ) # terminal cmd

  has_title() { [[ -n ${_args["-t arg"]} && -n ${_args["-T arg"]} ]]; }

  # Add title
  if has_title; then
    cmd+=( ${_args["-T arg"]} "${_args[-t arg]}" )
  fi

  # exec prefix and user command
  cmd+=(${_args["-X arg"]} ${_args["-x arg"]} -c)
  local user_cmd=("${_orb_dash_wildcard[*]};")
  has_title && user_cmd+=("${_args["-F arg"]}") || user_cmd+=("${_args["-f arg"]}")
  cmd+=("${user_cmd[*]}")

  "${cmd[@]}"
  orb_pass orb utils position_window -- -twp
}
