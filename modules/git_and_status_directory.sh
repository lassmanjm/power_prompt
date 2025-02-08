#! /bin/bash

# Module for CWD that changes color based on the status of the previous run command, 
# and turns the text into a hyperlink to the remote url. Adds the char  in front of
# CWD to indicate it is in a git repo dir or subdir. Default colors are dark grey
# on off-white for success, and white on red for failure.
#
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

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source  $SCRIPT_DIR/../utils/hyperlink.sh

function power_prompt_git_status_directory(){
  local OPTIND

  #DEFAULT: dark grey on off-white
  local success_fg=240 success_bg=255
  #DEFAULT: white on red
  local error_fg=15 error_bg=167


  # Use partial path by default
  local w="\W"
  while getopts "s:e:f" flag; do
    case "${flag}" in
      s)
	# Set colors for success, delimited by `,`
	IFS=',' read -r  success_fg success_bg <<< "$OPTARG"
	unset IFS
	;;
      e)
	# Set colors for error, delimited by `,`
	IFS=',' read -r  error_fg error_bg <<< "$OPTARG"
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
  if [[  "$1" -ne "0"  ]]; then
    fg=$error_fg
    bg=$error_bg
  fi
  git_branch=$(git branch 2>/dev/null | sed -n -e 's/^\* \(.*\)/\1/p')
  if [ -n "$git_branch" ]; then
    upstream=$(git rev-parse --abbrev-ref "@{upstream}" 2>/dev/null)
    if [ -n "$upstream" ]; then
      # Add hyperlink to github repo on cwd in prompt
      local url=$( git ls-remote --get-url origin | sed 's/github_pat_[^@]*@//' )
      w="$( power_prompt_hyperlink $url " $w" )"
    fi
  fi
  echo "$w,$fg,$bg"
  # echo "$w"
}

