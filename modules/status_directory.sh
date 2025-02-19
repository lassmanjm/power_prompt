#! /bin/bash

# Module for CWD that changes color based on the status of the previous run command.
# Default colors are dark grey on off-white for success, and white on red for failure.
# Flags:
#   -[f]ull path: If set, use the full cwd path, otherwise only use the lowest directory 
#   -[s]uccess colors: Change the default colors for successful previous command.
#     Should be comma delimited pair of 256 colors e.g. "240,255"
#   -[e]rror colors: Change the default colors for error on previous command.
#     Should be comma delimited pair of 256 colors e.g. "15,167"
#
# Usage:
#   Default:
#     export POWER_PROMPT_STRING="...;power_prompt_status_directory;..."
#   Custom:
#     export POWER_PROMPT_STRING="...;power_prompt_status_directory -f -s 240,255 -e 15,167;..."

function power_prompt_status_directory(){
  local OPTIND

  #DEFAULT: dark grey on off-white
  local success_fg=240 success_bg=255 success_delim=""
  #DEFAULT: white on red
  local error_fg=15 error_bg=167 error_delim=""


  # Use partial path by default
  local w="\W"
  while getopts "s:e:f" flag; do
    case "${flag}" in
      s)
        # Set colors for success, delimited by `,`
        IFS=',' read -r  success_fg success_bg success_delim <<< "$OPTARG"
        unset IFS
        ;;
      e)
        # Set colors for error, delimited by `,`
        IFS=',' read -r  error_fg error_bg error_delim <<< "$OPTARG"
        unset IFS
        ;;
      f)
	# Use full path.
	w="\w"
	;;
    esac
  done
  shift $((OPTIND - 1))
  local fg=$success_fg bg=$success_bg
  delim=$success_delim
  if [[  "$POWER_PROMPT_STATUS" -ne "0"  ]]; then
    fg=$error_fg
    bg=$error_bg
    delim=$error_delim
  fi
  POWER_PROMPT_OUTPUT="$w,$fg,$bg,$delim"
}
