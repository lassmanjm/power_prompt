#! /bin/bash

# Module for generic text
# Default colors are dark grey on off-white.
# Flags:
#   -[t]ext: Any text including escape sequences (https://tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html)
#     MUST NOT INCLUDE SPACES. If text including spaces is required, make a custom module
#   -[f]oreground color: The 256 color of the text font
#   -[b]ackground color: The 256 color of the text background
#
# Usage:
#   Default colors:
#     export POWER_PROMPT_STRING="...;power_prompt_text -t \u;..."
#   Custom colors:
#     export POWER_PROMPT_STRING="...;power_prompt_text -t \u -f 240 -b 255;..."

function power_prompt_text(){
  local fg=240 bg=255 text="" delimiter=""
  local OPTIND
  local check_status=false
  while getopts "t:b:f:d:" flag; do
    case "${flag}" in
      t)
	text="$OPTARG"
	;;
      f)
	fg=$OPTARG
	;;
      b)
	bg=$OPTARG
	;;
      d)
	delimiter=$OPTARG
	;;
    esac
  done
  shift $((OPTIND - 1))
  export POWER_PROMPT_OUTPUT="$text,$fg,$bg,$delimiter"
}
