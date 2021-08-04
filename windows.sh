# Position window
declare -A position_window_args=(
  ['-t arg']='title; REQUIRED'
  ['-p arg']='grid position; IN: fullscreen|left|right'
  ['-w arg']='workspace'
  ['-r']='retry; DEFAULT: true'
  ['-R']='retry timeout sec; DEFAULT: 5'
  ['-I']='retry interval; DEFAULT: 0.3'
); function position_window() {
  local title="${_args["-t arg"]}"
  local position="${_args["-p arg"]}"
  local workspace="${_args["-w arg"]}"
  local timeout=${_args[-R]}
  local interval=${_args[-I]}
  local cmd=( wmctrl -r "$title" )

  local timer=0
  while [[ $timer < $timeout ]] && ! _args_to orb window_exists -- -t; do
    timer+=$interval
    sleep "${interval}s"
  done

  [[ "$timer" -gt "$timeout" ]] && return

  if [[ -n "$workspace" ]]; then
    workspace_cmd=( "${cmd[@]}" -t "$workspace" )
    "${workspace_cmd[@]}"
  fi

  if [[ -n $position ]]; then
    position_cmd=( "${cmd[@]}" $(wmctrl_position_param) )
    "${position_cmd[@]}"
  fi
}


wmctrl_position_param() {
  [[ -n "$title" ]] && window_id=$(xdotool search --name "$title")

  [[ "$position" == "fullscreen" ]] && echo "-b toggle,fullscreen" && return

  # Else calculate left/right
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
    'left')
      pos_x=$screen_x_left
      echo "-e 0,$pos_x,0,$wh,$h"
      ;;

    'right')
      pos_x=$(( $screen_x_left + $screen_width / 2 ))
      echo "-e 0,$pos_x,0,$wh,$h"
      ;;
  esac
}


# Kill windows
declare -A kill_windows_args=(
  ['*']='window_titles'
  ['-R']='retry timeout sec; DEFAULT: 5'
  ['-I']='retry interval; DEFAULT: 0.3'
); function kill_windows() {
  for title in "${_args_wildcard[@]}"; do
    wmctrl -c "$title" > /dev/null 2>&1
  done

  local timer=0
  while [[ $timer < ${_args[-R]} ]] && orb window_exists -t "$title"; do
    timer+=${_args[-I]}
    sleep "${_args[-I]}s"
  done
}


declare -A window_exists_args=(
  ['-t arg']='title; REQUIRED'
); function window_exists() {
  [[ $(wmctrl -l | grep "${_args["-t arg"]}" 2>&1 | wc -l) > 0 ]]
}
