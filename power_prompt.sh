#! /bin/bash

# Override these values to configure power prompt:
# - POWER_PROMPT_MODULES: Select modules, module specific settings (through flags and parameters),
#     and module order. Modules are are functions that set the POWER_PROMPT_OUTPUT variable to a ','
#     delimited string of text,forground color, background color, and optional delimiter. Examples
#     can be found in the 'modules' directory.
# - POWER_PROMPT_DELIMITER: Delimiting string that determines the shape of each module.
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
# - POWER_PROMPT_BEGIN: Start string that determines the shape of the left side of the
#     first module.
#     Examples:
#       - : gives modules the shape  ███████████ (to match Default)
#
#       - : gives modules the shape  ███████████
#
#       - : gives modules the shape  ███████████
#
#       - Any other character in your font. Examples can be found in delimiters.txt.
#           Must be counted as single width by bash or will cause bugs with scroll
#           history (e.g. try 󰓗 and see what happens when scrolling with arrow keys)

if [[ -z $POWER_PROMPT_MODULES ]]; then
 export POWER_PROMPT_MODULES=" \
  power_prompt_statuses -pg -f 11 -b 98; \
  power_prompt_text -t '\u' -f 15 -b 68; \
  power_prompt_text -t '\h' -f 15 -b 110; \
  power_prompt_git_status_directory; \
  "
fi

if [[ -z $POWER_PROMPT_DELIMITER ]]; then
 export POWER_PROMPT_DELIMITER=""
fi

#  can be used to match default delimeter
if [[ -z $POWER_PROMPT_BEGIN ]]; then
 export POWER_PROMPT_BEGIN=""
fi

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source $SCRIPT_DIR/utils/format.sh
for file in $SCRIPT_DIR/modules/*.sh; do
  source $file
done

function power_prompt_builder(){
  POWER_PROMPT_STATUS="$?"
  local run_befores

  # Run all methods in POWER_PROMPT_RUN_BEFORE
  IFS=';' read -r -a run_befores <<< "$POWER_PROMPT_RUN_BEFORE"
  unset IFS
  for method in "${run_befores[@]}"; do
    eval "$method"
  done

  local modules
  PS1="\n"

  # Extract module calls
  IFS=';' read -r -a modules <<< "$POWER_PROMPT_MODULES"
  unset IFS
  local text texts=() fgs fgs=() bgs bgs=() delimiter delimiters=()
  for module in "${modules[@]}"; do
    # Erase previous output
    unset POWER_PROMPT_OUTPUT
    # Call the module
    eval "$module"
    IFS=',' read -r  text fg bg delimiter <<< "$POWER_PROMPT_OUTPUT"

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
    if [[ -n "$POWER_PROMPT_BEGIN" ]] && [[ $i -eq 0 ]]; then
      begin="$POWER_PROMPT_BEGIN"
    fi
    # Format each module output and append to PS1
    PS1="$PS1$( power_prompt_format -t " ${texts[$i]} " -f "${fgs[$i]}" -b "${bgs[$i]}" -n "$next_background" -e "${delimiters[$i]}"  -s "$begin" )"
  done

  # Run all methods in POWER_PROMPT_RUN_AFTER
  IFS=';' read -r -a run_afters <<< "$POWER_PROMPT_RUN_AFTER"
  unset IFS
  for method in "${run_afters[@]}"; do
    eval "$method"
  done
  POWER_PROMPT_PREVIOUS_WD=$(pwd)
  POWER_PROMPT_PREVIOUS_TIMESTAMP=$(date +%s)
  PS1="$PS1 "
}

export PROMPT_COMMAND='power_prompt_builder'

