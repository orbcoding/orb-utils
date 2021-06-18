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


# Kill windows
declare -A kill_windows_args=(
  ['*']='window_titles'
); function kill_windows() {
  for window in ${_args_wildcard[@]}; do
    wmctrl -c "$window" # > /dev/null 2>&1
  done
}
