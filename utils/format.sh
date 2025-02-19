#! /bin/bash

function power_prompt_format () {
  local OPTIND
  local text foreground background next_background start end
  while getopts "t:f:b:n:p:s:e:" flag; do
    case "${flag}" in
      t)
        text=$OPTARG
        ;;
      f)
        foreground=$OPTARG
        ;;
      b)
        background=$OPTARG
        ;;
      n)
        next_background=$OPTARG
        ;;
      p)
        previous_background=$OPTARG
        ;;
      s)
        start=$OPTARG
        ;;
      e)
        end=$OPTARG
        ;;
    esac
  done
  if [[ -n $previous_background ]]; then
    previous_background=";48;5;$previous_background"
  fi
  if [[ -n $start ]]; then
    start="\[\e[38;5;${background}${previous_background}m\]$start\[\e[0m\]"
  fi
  if [[ -n $next_background ]]; then
    next_background=";48;5;$next_background"
  fi
  # Display begginning char if this is the first module, then text on givin backround color,
  # then delimiter in background color on next background color background
  echo "$start\[\e[1;38;5;${foreground};48;5;${background}m\]${text}\[\e[0m\]\[\e[38;5;${background}${next_background}m\]$end\[\e[0m\]"
}

