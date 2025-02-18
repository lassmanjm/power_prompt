#! /bin/bash

# Override these values to configure power prompt:
# - POWER_PROMPT_STRING: Select modules, module specific settings (through flags and parameters),
#     and module order
# - POWER_PROMPT_DELIMITER: Delimiting character that determines the shape of each module.
#     Examples:
#       - : gives modules the shape  ███████████ (Default)
#
#       - : gives modules the shape  ███████████
#
#       - : gives modules the shape  ███████████
#
#       - Any other character in your font. Examples can be found in delimiters.txt.
#           Must be counted as single width by bash or will cause bugs with scroll
#           history (e.g. try 󰓗 and see what happens when scrolling with arrow keys)

export DEFAULT_POWER_PROMPT_STRING="power_prompt_statuses -pg -f 11 -b 98;power_prompt_text -t \u -f 15 -b 68;power_prompt_text -t \h -f 15 -b 110;power_prompt_git_status_directory;"
if [[ -z $POWER_PROMPT_STRING ]]; then
 export POWER_PROMPT_STRING=$DEFAULT_POWER_PROMPT_STRING
fi

export DEFAULT_POWER_PROMPT_DELIMITER=""
if [[ -z $POWER_PROMPT_DELIMITER ]]; then
 export POWER_PROMPT_DELIMITER=$DEFAULT_POWER_PROMPT_DELIMITER
fi

#  can be used to match default delimeter
export DEFAULT_POWER_PROMPT_BEGIN_CHAR=""
if [[ -z $POWER_PROMPT_BEGIN_CHAR ]]; then
 export POWER_PROMPT_BEGIN_CHAR=$DEFAULT_POWER_PROMPT_BEGIN_CHAR
fi

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
for file in $SCRIPT_DIR/modules/*.sh; do
  source $file
done

function power_prompt_format () {
  local OPTIND
  local text foreground background next_background start end
  while getopts "t:f:b:n:s:e:" flag; do
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
      s)
        start=$OPTARG
        ;;
      e)
        end=$OPTARG
        ;;
    esac
  done
  if [[ -n $start ]]; then
    start="\[\e[38;5;${background}m\]$start\[\e[0m\]"
  fi
  if [[ -n $next_background ]]; then
    next_background=";48;5;$next_background"
  fi
  # Display begginning char if this is the first module, then text on givin backround color,
  # then delimiter in background color on next background color background
  echo "$start\[\e[1;38;5;${foreground};48;5;${background}m\]${text}\[\e[0m\]\[\e[38;5;${background}${next_background}m\]$end\[\e[0m\]"
}

function power_prompt_builder(){
  POWER_PROMPT_STATUS="$?"
  if declare -f POWER_PROMPT_RUN_BEFORE &>/dev/null; then
    POWER_PROMPT_RUN_BEFORE
  fi
  local modules
  PS1="\n"
  #
  # Extract module calls
  IFS=';' read -r -a modules <<< "$POWER_PROMPT_STRING"
  unset IFS
  local text texts=() fgs fgs=() bgs bgs=() delimiter delimiters=()
  for module in "${modules[@]}"; do
    # Call the module
    result="$(eval "$module" )"
    IFS=',' read -r  text fg bg delimiter <<< "$result"

    # Skip the module if the text is empty
    if [[ -z $text ]]; then continue; fi
    # Default colors
    [[ -z $fg ]] && fg=240
    [[ -z $bg ]] && bg=255
    [[ -z $delimiter ]] && delimiter=$POWER_PROMPT_DELIMITER
    texts+=("$text")
    fgs+=("$fg")
    bgs+=("$bg")
    delimiters+=("$delimiter")
  done
  n="${#texts[@]}"
  for i in $(seq 0 $((n-1))); do 
    # Set the next backgound from the next module
    local next_background=""
    if [[ $i -lt $((n-1)) ]]; then
      next_background="${bgs[$((i+1))]}"
    fi
    # Add beginning character to module if it is the first and the begin char is defined.
    begin=""
    if [[ -n "$POWER_PROMPT_BEGIN_CHAR" ]] && [[ $i -eq 0 ]]; then
      begin="$POWER_PROMPT_BEGIN_CHAR"
    fi
    # Format each module output and append to PS1
    PS1="$PS1$( power_prompt_format -t " ${texts[$i]} " -f "${fgs[$i]}" -b "${bgs[$i]}" -n "$next_background" -e "${delimiters[$i]}"  -s "$begin" )"
  done
  if declare -f POWER_PROMPT_RUN_AFTER &>/dev/null; then
    POWER_PROMPT_RUN_AFTER
  fi
  POWER_PROMPT_PREVIOUS_WD=$(pwd)
  POWER_PROMPT_PREVIOUS_TIMESTAMP=$(date +%s)
  PS1="$PS1 "
}

export PROMPT_COMMAND='power_prompt_builder'

