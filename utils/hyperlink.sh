#! /bin/bash

# Helper function to create heyperlink text for PS1
#
# Usage:
#   power_prompt_hyperlink $url $text

function power_prompt_hyperlink(){
  echo "\[\e]8;;$1\e\\\\\]$2\[\e]8;;\e\\\\\]"
}
