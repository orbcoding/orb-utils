# Kill rails
declare -A kill_rails_args=(
  ['1']='port; DEFAULT: 3000'
); function kill_rails() {
  pid=$(lsof -i tcp:$1 | grep ruby | head -n 1 | tr -s ' ' | cut -d ' ' -f2)
  [[ -n $pid ]] && echo $pid && kill -9 $pid
}
