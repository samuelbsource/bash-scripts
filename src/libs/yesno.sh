#!/bin/bash
# -----------------------------------------------------------------------------
# is_yes_no.sh - Yes/No Value Detection Library
#
# Unified way to check if the string, such as environment variable,
#   represents truthy or falsy value.
#
# Functions:
#   is_yes: Returns 0 (true) if input is a truthy value, 1 (false) otherwise.
#   is_no:  Returns 0 (true) if input is a falsy value, 1 (false) otherwise.
# -----------------------------------------------------------------------------

# guard
if declare -f is_no > /dev/null; then
  return 0
fi


#######################################
# Check if the provided value is falsy: n, no, f, false, 0, off, null, "" (empty string)
# Arguments:
#   A value to check
# Returns:
#   0 if thing was falsy, 1 if truthy
#######################################
is_no() {
  local input_str="${1-}"
  local lower_str

  # Empty string
  if [[ -z "$input_str" ]]; then
    return 0
  fi

  lower_str="${input_str,,}"
  case "$lower_str" in
    n|no|f|false|0|off|null)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

#######################################
# Check if the provided value is truthy - any non falsy value.
# Arguments:
#   A value to check
# Returns:
#   0 if thing was truthy, 1 if falsy
#######################################
is_yes() {
  ! is_no "$1"
}
