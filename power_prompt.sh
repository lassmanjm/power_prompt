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

function power_prompt_colorize () {
  # If there are more than for aruments use the fifth for the beginning char. Should only be used for the first module.
  begin=""
  if [[ $# -gt 4 ]]; then
    begin="\[\e[38;5;${3}m\]$5\[\e[0m\]"
  fi
  # If there are more than three, the fourth describes the next section background color. Should be empty for the final module.
  next_bg=""
  if [[ $# -gt 3 ]]; then
    next_bg=";48;5;$4"
  fi
  # Display begginning char if this is the first module, then text on givin backround color,
  # then delimiter in background color on next background color background
  echo "$begin\[\e[1;38;5;${2};48;5;${3}m\]${1}\[\e[0m\]\[\e[38;5;${3}${next_bg}m\]$POWER_PROMPT_DELIMITER\[\e[0m\]"
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
  local texts=() fgs=() bgs=()
  for module in "${modules[@]}"; do
    # Call the module
    result="$( $module )"
    IFS=',' read -r  text fg bg <<< "$result"

    # Skip the module if the text is empty
    if [[ -z $text ]]; then continue; fi
    # Default colors
    [[ -z $fg ]] && fg=240
    [[ -z $bg ]] && bg=255
    texts+=("$text")
    fgs+=("$fg")
    bgs+=("$bg")
  done
  n="${#texts[@]}"
  for i in $(seq 0 $((n-1))); do 
    # Set the next backgound from the next module
    local next_backgroung=""
    if [[ $i -lt $((n-1)) ]]; then
      next_backgroung="${bgs[$((i+1))]}"
    fi
    # Add beginning character to module if it is the first and the begin char is defined.
    begin=""
    if [[ -n "$POWER_PROMPT_BEGIN_CHAR" ]] && [[ $i -eq 0 ]]; then
      begin="$POWER_PROMPT_BEGIN_CHAR"
    fi
    # Format each module output and append to PS1
    PS1="$PS1$(power_prompt_colorize " ${texts[$i]} " "${fgs[$i]}" "${bgs[$i]}" $next_backgroung $begin)"
  done
  if declare -f POWER_PROMPT_RUN_AFTER &>/dev/null; then
    POWER_PROMPT_RUN_AFTER
  fi
  POWER_PROMPT_PREVIOUS_WD=$(pwd)
  POWER_PROMPT_PREVIOUS_TIMESTAMP=$(date +%s)
  PS1="$PS1 "
}

export PROMPT_COMMAND='power_prompt_builder'

