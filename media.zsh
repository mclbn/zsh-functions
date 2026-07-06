mkgif() {
  emulate -L zsh
  setopt no_unset

  if (( $# < 3 )); then
    print -ru2 "usage: mkgif <source> <start> <duration> [output] [fps] [width]"
    return 2
  fi

  local src=$1 start=$2 dur=$3
  local out=${4:-}
  local fps=${5:-15}
  local width=${6:-0}
  [[ -z $out ]] && out=${src:r}.gif

  if ! command -v ffmpeg >/dev/null 2>&1; then
    print -ru2 "mkgif: ffmpeg not found in PATH"
    return 1
  fi
  if [[ ! -f $src ]]; then
    print -ru2 "mkgif: no such file: $src"
    return 1
  fi

  local vf="fps=${fps},scale=iw*sar:ih:flags=lanczos,setsar=1"
  (( width > 0 )) && vf+=",scale=${width}:-2:flags=lanczos"
  vf+=",split[a][b];[a]palettegen[p];[b][p]paletteuse"

  ffmpeg -hide_banner -loglevel error -stats \
    -ss "$start" -t "$dur" -i "$src" \
    -filter_complex "$vf" \
    -loop 0 -an -y "$out" \
  && print -r "wrote $out"
}
