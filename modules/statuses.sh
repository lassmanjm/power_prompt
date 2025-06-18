#! /bin/bash

# Module for several statuses, including if uncommitted git changes in the current repo and
# ahead/behind upstream (if CWD is in a git repo), and if a python VENV is activated.
# Default colors are dark grey on off-white.
# Flags:
#   -[g]it: If set, include git statuses (uncommitted changes, ahead behind)
#   -[G]it: Same as above, but takes argument to set the sybmol displayed when
#     there are uncomitted changes in the current repo. DEFAULT: 
#   -[p]ython venv: If set, include status if python VENV is activated
#   -[P]ython venv: Same as above, but takes argument to set the sybmol displayed when
#     a python VENV is activated. DEFAULT: 
#   -[f]oreground color: The 256 color of the text font. DEFAULT: dark grey.
#   -[b]ackground color: The 256 color of the text background. DEFAULT: off-white
#   -[d]elimiter: The delimiter string for the module. Default: ""
#   -[B]egin: The beginning string of the module. Default: ""
#   -[r]efresh rate: Time in seconds between git refreshes. I.e., until that time has passed,
#     a git fetch will not be run to compare to upstream. DEFAULT: 30
#
# Usage:
#   Default:
#     export POWER_PROMPT_STRING="...;power_prompt_statuses -pg;..."
#   Custom:
#     export POWER_PROMPT_STRING="...;power_prompt_statuses -p -f 240 -b 255;..."

function power_prompt_statuses(){
  # Default values
  local fg=240 bg=255 delimiter begin text="" GIT=false PYTHON=false git_sign="" python_sign="" refresh_rate=30
  local OPTIND
  while getopts "f:b:d:B:gG:pP:r:" flag; do
    case "${flag}" in
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
      g)
	# Show git statuses
	GIT=true
	;;
      G)
	# Show git statuses and set unsubmitted changes symbol
	GIT=true
	git_sign=$OPTARG
	;;
      p)
	# Show python venv status
	PYTHON=true
	;;
      P)
	# Show python venv status and set symbol
	PYTHON=true
	python_sign=$OPTARG
	;;
      r)
	# Rate at which to refresh git information from upstream (run git fetch)
	refresh_rate=$OPTARG
	;;
    esac
  done

  shift $((OPTIND - 1))
  local statuses=""

  # Check for VENV
  if [[ $PYTHON == "true" ]] && [[ -n "$VIRTUAL_ENV" ]]; then
    statuses="$python_sign "
  fi

  # Check if current dir is inside a git repo
  local git_branch=$(git branch 2>/dev/null | sed -n -e 's/^\* \(.*\)/\1/p')
  if [[ $GIT == "true" ]] && [[ -n "$git_branch" ]]; then

    # check if the branch has an upstream (remote) branch
    local upstream=$(git rev-parse --abbrev-ref "@{upstream}" 2>/dev/null)
    if [ -n "$upstream" ]; then

      local curr_time=$(date +%s)
      #Only fetch if the directory has changed or it has been long enogh
      if [[ $(pwd) != $POWER_PROMPT_PREVIOUS_WD ]] || [[ $((curr_time-POWER_PROMPT_GIT_LAST_UPSTREAM_CHECK)) -gt $refresh_rate ]]; then
	# compare local and remote hashes (this is faster than a fetch)
	local remote_hash=$(git ls-remote origin -h refs/heads/$git_branch 2>/dev/null| awk '{print $1}')
	local local_hash=$(git rev-parse HEAD)

	# only fetch if the hashes do not match
	if [ "$remote_hash" != "$local_hash" ]; then
	  git fetch --quiet >/dev/null 2>&1
	fi
	POWER_PROMPT_GIT_LAST_UPSTREAM_CHECK=$(date +%s)
      fi

      # get the number of commits ahead/behind
      local git_ahead_behind=$(git rev-list --left-right --count "$upstream"...HEAD 2>/dev/null)
      local behind_count=$(echo "$git_ahead_behind" | awk '{print $1}')
      local ahead_count=$(echo "$git_ahead_behind" | awk '{print $2}')

      # format the ahead/behind indicator
      if [[ "$ahead_count" -gt 0 && "$behind_count" -gt 0 ]]; then
        statuses=" $statuses"
      elif [ "$ahead_count" -gt 0 ]; then
        statuses=" $statuses"
      elif [ "$behind_count" -gt 0 ]; then
        statuses=" $statuses"
      fi
    fi
    # add git_sign if there are uncommitted changes in git repo
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      statuses="$git_sign $statuses"
    fi
  fi
  statuses="$(echo "$statuses" | sed 's/[[:space:]]*$//')"
  POWER_PROMPT_OUTPUT="#!$statuses,$fg,$bg,$delimiter,$begin"
}
