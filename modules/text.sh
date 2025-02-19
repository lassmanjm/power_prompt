#! /bin/bash

# Module for generic text
# Default colors are dark grey on off-white.
# Flags:
#   -[t]ext: Any text including escape sequences (https://tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html)
#     MUST NOT INCLUDE SPACES. If text including spaces is required, make a custom module
#   -[f]oreground color: The 256 color of the text font
#   -[b]ackground color: The 256 color of the text background
#   -[d]elimiter: The delimiter string for the module. Default: ""
#   -[B]egin: The beginning string of the module. Default: ""
#
# Usage:
#   Default colors:
#     export POWER_PROMPT_STRING="...;power_prompt_text -t \u;..."
#   Custom colors:
#     export POWER_PROMPT_STRING="...;power_prompt_text -t \u -f 240 -b 255;..."

function power_prompt_text(){
  local fg=240 bg=255 text="" delimiter="" begin=""
  local OPTIND
  local check_status=false
  while getopts "t:b:f:d:B:" flag; do
    case "${flag}" in
      t)
	# Display text
	text="$OPTARG"
	;;
      f)
	# Foreground color
	fg=$OPTARG
	;;
      b)
	# Background color
	bg=$OPTARG
	;;
      d)
	# Delimiter string
	delimiter=$OPTARG
	;;
      B)
	# Begin string
	begin=$OPTARG
	;;
    esac
  done
  shift $((OPTIND - 1))
  POWER_PROMPT_OUTPUT="$text,$fg,$bg,$delimiter,$begin"
}
