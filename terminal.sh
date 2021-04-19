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
  position_window _pass_flags -- -tp
}

# Position window
declare -A position_window_args=(
  ['-t arg']='title'
  ['-p arg']='grid position; IN: fullscreen|left|right'
); function position_window() {
  title="${_args["-t arg"]}"
  position="${_args["-p arg"]}"

  [[ -n "$title" ]] && window_id=$(xdotool search --name "$title")
  [[ -z "$window_id" || -z "$position" ]] && return

  window=$(xwininfo -id "$window_id")
  window_x_left=$(echo -e "$window" | grep "Absolute upper-left X" | grep "Absolute upper-left X" | awk '{print $NF}')
  screens=$(xrandr | grep -w connected  | sed 's/primary //' | awk -F'[ +]' '{print $1,$3,$4}')
  screens_nr=$(echo "$screens" | wc -l)

  for n in $(seq 1 $screens_nr); do
    screen=($(echo "$screens" | sed "${n}q;d" ))
    name="${screen[0]}"
    screen_x_left="${screen[2]}" # offset
    screen_x_right=$((${screen[1]/x*/} + $screen_x_left))

    if [[ "$window_x_left" -ge "$screen_x_left" && "$window_x_left" -le "$screen_x_right" ]]; then
      break; # and leave values
    fi
  done

  # Split screen
  screen_width=$(($screen_x_right - $screen_x_left))
  screen_height=$((${screen[1]#*x}))

  offset_vert=0
  offset_horz=0
  wh=$(( $screen_width / 2 - $offset_horz ))
  h=$(( $screen_height - $offset_vert ))
  hh=$(( $h / 2 ))

  case "$position" in
    'fullscreen')
      grid_cmd=( wmctrl -r "$title" -b toggle,fullscreen )
      ;;

    'left')
      pos_x=$screen_x_left
      grid_cmd=( wmctrl -r "$title" -e 0,$pos_x,0,$wh,$h )
      ;;

    'right')
      pos_x=$(( $screen_x_left + $screen_width / 2 ))
      grid_cmd=( wmctrl -r "$title" -e 0,$pos_x,0,$wh,$h )
      ;;
  esac

  "${grid_cmd[@]}"
}

# Kill rails
declare -A kill_rails_args=(
  ['1']='port; DEFAULT: 3000'
); function kill_rails() {
  pid=$(lsof -i tcp:$1 | grep ruby | head -n 1 | tr -s ' ' | cut -d ' ' -f2)
  [[ -n $pid ]] && echo $pid && kill -9 $pid
}


# Kill windows
declare -A kill_windows_args=(
  ['*']='window_titles'
); function kill_windows() {
  for window in ${_args_wildcard[@]}; do
    wmctrl -c "$window"
  done
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
