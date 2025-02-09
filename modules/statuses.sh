#! /bin/bash

# Module for several statuses, including if uncommitted git changes in the current repo and
# ahead/behind upstream (if CWD is in a git repo), and if a python VENV is activated.
# Default colors are dark grey on off-white.
# Flags:
#   -[g]it: If set, include git statuses (uncommitted changes, ahead behind)
#   -[p]ython venv: If set, include status if python VENV is activated
#   -[f]oreground color: The 256 color of the text font
#   -[b]ackground color: The 256 color of the text background
#
# Usage:
#   Default:
#     export POWER_PROMPT_STRING="...;power_prompt_statuses -pg;..."
#   Custom:
#     export POWER_PROMPT_STRING="...;power_prompt_statuses -p -f 240 -b 255;..."


function power_prompt_statuses(){
  local fg=240 bg=255 text="" GIT=false PYTHON=false
  local OPTIND
  while getopts "b:f:gp" flag; do
    case "${flag}" in
      f)
	fg=$OPTARG
	;;
      b)
	bg=$OPTARG
	;;
      g)
	GIT=true
	;;
      p)
	PYTHON=true
	;;
    esac

  done
  shift $((OPTIND - 1))
  local statuses=""
  if [[ $PYTHON == "true" ]] && [[ -n "$VIRTUAL_ENV" ]]; then
    statuses=" "
  fi

  git_branch=$(git branch 2>/dev/null | sed -n -e 's/^\* \(.*\)/\1/p')
  if [[ $GIT == "true" ]] && [[ -n "$git_branch" ]]; then
    local remote_hash=$(git ls-remote origin -h refs/heads/$git_branch 2>/dev/null| awk '{print $1}')
    local local_hash=$(git rev-parse head)
    # only fetch if the hashes do not match
    if [ "$remote_hash" != "$local_hash" ]; then
      git fetch --quiet >/dev/null 2>&1
    fi

    # check if the branch has an upstream (remote) branch
    local upstream=$(git rev-parse --abbrev-ref "@{upstream}" 2>/dev/null)
    if [ -n "$upstream" ]; then
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
    # add 󰫢 if there are uncommitted changes in git repo
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      statuses=" $statuses"
    fi
  fi
  statuses="$(echo "$statuses" | sed 's/[[:space:]]*$//')"
  echo "$statuses,$fg,$bg"
}
