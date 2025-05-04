#!/bin/bash
# -----------------------------------------------------------------------------
# tstyle.sh - Terminal Output Styling Library
#
# A highly customizable way to uniformally display messages.
#
# Environment Variables:
#   NO_COLOR: Any non-empty value disables color
#
# Functions:
#   tstyle_title
#   tstyle_section
#   tstyle_subsection
#   tstyle_step
#   tstyle_pstep
#   tstyle_substep
#   tstyle_info
#   tstyle_ok
#   tstyle_success
#   tstyle_warn
#   tstyle_error
#   tstyle_ul
#   tstyle_ol
#   tstyle_code
#   tstyle_enter_level
#   tstyle_exit_level
#   tstyle_newline
# -----------------------------------------------------------------------------

# guard
if declare -f tstyle_title > /dev/null; then
    return 0
fi

# Current padding "level"
_TS_PAD_LEVEL=1

# common escape sequences
_TS_RESET='\e[0m'
_TS_BOLD='\e[1m'
_TS_UNDERLINE='\e[4m'
_TS_FG_GREEN='\e[32m'
_TS_FG_YELLOW='\e[33m'
_TS_FG_MAGENTA="\e[35m"
_TS_FG_CYAN="\e[36m"
_TS_FG_BRIGHT_BLACK="\e[90m"
_TS_FG_BRIGHT_RED='\e[91m'
_TS_FG_BRIGHT_GREEN='\e[92m'
_TS_FG_BRIGHT_YELLOW='\e[93m'
_TS_FG_BRIGHT_BLUE="\e[94m"
_TS_BG_RED='\e[41m'
_TS_CUR_SAVE="\e[7"
_TS_CUR_RESTORE="\e[8"
_TS_ERASE_EID="\e[J"
_TS_ERASE_CUES="\e[0J"
_TS_LINE_CLS="\e[K"

# theme
_TS_LEVEL_PAD_CHAR="  "
_TS_TITLE_WIDTH=40
_TS_TITLE_LINE_CHAR="="
_TS_TITLE_LINE_STYLE="$_TS_BOLD$_TS_FG_BRIGHT_BLUE"
_TS_TITLE_TEXT_STYLE="$_TS_BOLD$_TS_FG_BRIGHT_BLUE"
_TS_SECTION_WIDTH="$_TS_TITLE_WIDTH"
_TS_SECTION_LINE_CHAR="-"
_TS_SECTION_TEXT_STYLE="$_TS_FG_MAGENTA"
_TS_SUBSECTION_TEXT_STYLE="$_TS_UNDERLINE$_TS_FG_CYAN"
_TS_STEP_BULLET_CHAR=" -> "
_TS_STEP_BULLET_STYLE="$_TS_FG_CYAN"
_TS_STEP_TEXT_STYLE=""
_TS_PSTEP_BAR_LEFT="("
_TS_PSTEP_BAR_RIGHT=")"
_TS_PSTEP_BULLET_CHAR="$_TS_STEP_BULLET_CHAR"
_TS_PSTEP_BULLET_STYLE="$_TS_STEP_BULLET_STYLE"
_TS_PSTEP_TEXT_STYLE="$_TS_STEP_TEXT_STYLE"
_TS_SUBSTEP_BULLET_STYLE="$_TS_FG_CYAN"
_TS_SUBSTEP_BULLET_CHAR=" * "
_TS_SUBSTEP_TEXT_STYLE=""
_TS_LOG_TEXT_STYLE=""
_TS_LOG_INFO="$_TS_FG_GREEN[INFO]$_TS_RESET"
_TS_LOG_OK="$_TS_FG_BRIGHT_GREEN[OK]$_TS_RESET"
_TS_LOG_SUCCESS="$_TS_FG_BRIGHT_GREEN[SUCCESS]$_TS_RESET"
_TS_LOG_WARN="$_TS_FG_BRIGHT_YELLOW[WARN]$_TS_RESET"
_TS_LOG_ERROR="$_TS_FG_BRIGHT_RED[ERROR]$_TS_RESET"
_TS_LOG_CRITICAL_WIDTH="$_TS_TITLE_WIDTH"
_TS_LOG_CRITICAL_STYLE="$_TS_BG_RED"
_TS_UL_BULLET_STYLE=" * "
_TS_UL_TEXT_STYLE=""
_TS_OL_BULLET_STYLE="%2d. "
_TS_OL_TEXT_STYLE=""

_TS_CODE_PROMPT_STYLE="$_TS_FG_BRIGHT_BLACK"    # Prompt symbol ($ , #)
_TS_CODE_COMMAND_STYLE="$_TS_FG_GREEN"          # Command name (grep, ls, tail)
_TS_CODE_OPTION_STYLE="$_TS_FG_BRIGHT_BLUE"     # Options/Flags (-i, -n, --long)
_TS_CODE_STRING_STYLE="$_TS_FG_YELLOW"          # String literals ('error', "pattern")
_TS_CODE_NUMBER_STYLE="$_TS_FG_YELLOW"          # Numerical arguments (5, 1024)
_TS_CODE_FILEPATH_STYLE="$_TS_UNDERLINE"        # File paths (/var/log/syslog)
_TS_CODE_OPERATOR_STYLE="$_TS_BOLD"             # Operators (|, &&, >)

_TS_OUTPUT_WIDTH="120"
_TS_OUTPUT_HEIGHT="10"
_TS_OUTPUT_BORDER_CHARS=("─" "┌" "┐" "└" "┘")
_TS_OUTPUT_BORDER_STYLE="$_TS_FG_GREEN"

# Helpers for formatting code
_tsctp() { printf "${_TS_CODE_PROMPT_STYLE}$@${_TS_RESET}"; }
_tsctc() { printf "${_TS_CODE_COMMAND_STYLE}$@${_TS_RESET}"; }
_tscos() { printf "${_TS_CODE_OPTION_STYLE}$@${_TS_RESET}"; }
_tscst() { printf "${_TS_CODE_STRING_STYLE}$@${_TS_RESET}"; }
_tscnu() { printf "${_TS_CODE_NUMBER_STYLE}$@${_TS_RESET}"; }
_tscfp() { printf "${_TS_CODE_FILEPATH_STYLE}$@${_TS_RESET}"; }
_tscop() { printf "${_TS_CODE_OPERATOR_STYLE}$@${_TS_RESET}"; }

# Helpers for cursor control
_tscsave() { printf "$_TS_CUR_SAVE"; }
_tscrestore() { printf "$_TS_CUR_RESTORE"; }
_rseues() { printf "$_TS_ERASE_CUES"; }

#######################################
# A "hook" that is called before any function
# Arguments:
#   $1: function_name
#   $*: arguments
#######################################
_tstyle_before_hook() {
  return 0;
}

#######################################
# A "hook" that is called after any function
# Arguments:
#   $1: function_name
#   $*: arguments
#######################################
_tstyle_after_hook() {
  return 0;
}

#######################################
# Helper method to print given character n times for formatting
# Arguments:
#   $1: Length
#   $2: Character
#######################################
_tstyle_repeat_char() {
  local len="$1"
  local char="$2"
  for((i=0;i<len;i++)); do
    printf "$char"
  done
}

#######################################
# "Enter" one level deeper, forcing all following
#   output to be padded by 2 additional spaces.
#######################################
tstyle_enter_level() {
  _TS_PAD_LEVEL=$(($_TS_PAD_LEVEL + 1))
}

#######################################
# "Exit" one padding level
#######################################
tstyle_exit_level() {
  _TS_PAD_LEVEL=$(($_TS_PAD_LEVEL - 1))
}

#######################################
# Skip n number of lines to provide some spacing
# Arguments:
#   Number of newlines to print
#######################################
tstyle_newline() {
  local n="${1:-1}"
  for((i=0;i<n;i++)); do
    printf "\n"
  done
}

#######################################
# Print "title" to the terminal, a very stand out piece of text.
#   Resets the "level" to 1
# Arguments:
#   A message to print
#######################################
tstyle_title() {
  _tstyle_before_hook tstyle_title "$@"
  local text="$1"
  local text_len=${#text}
  local padding_length=$((($_TS_TITLE_WIDTH - text_len) / 2))
  local padding=$(_tstyle_repeat_char $padding_length " ")
  local line=$(_tstyle_repeat_char $_TS_TITLE_WIDTH "$_TS_TITLE_LINE_CHAR")
  _TS_PAD_LEVEL=1
  
  printf "%b\n" "${_TS_TITLE_LINE_STYLE}${line}${_TS_RESET}"
  printf "%b" "${_TS_TITLE_TEXT_STYLE}${padding}${text}${padding}${_TS_RESET}"

  # Handle odd length padding if necessary
  [[ $(((text_len + padding_length * 2) % 2)) -ne 0 ]] && printf " "

  printf "\n"
  printf "%b\n" "${_TS_TITLE_LINE_STYLE}${line}${_TS_RESET}"
  _tstyle_after_hook tstyle_title "$@"
}

#######################################
# Print "section" to the terminal, stands out, but less than title.
#   Resets the "level" to 1
# Arguments:
#   A message to print
#######################################
tstyle_section() {
  _tstyle_before_hook tstyle_section "$@"
  local text="$1"
  local text_len=${#text}
  local padding_length=$(((($_TS_TITLE_WIDTH - text_len) / 2) - 1))
  local padding=$(_tstyle_repeat_char $padding_length "$_TS_SECTION_LINE_CHAR")
  _TS_PAD_LEVEL=1

  printf "%b" "${_TS_SECTION_TEXT_STYLE}${padding} ${text} ${padding}${_TS_RESET}"

  # Handle odd length padding if necessary
  [[ $(((text_len + padding_length * 2) % 2)) -ne 0 ]] && printf "$_TS_SECTION_TEXT_STYLE$_TS_SECTION_LINE_CHAR$_TS_RESET"
  printf "\n"
  _tstyle_after_hook tstyle_section "$@"
}

#######################################
# Print "subsection" to the terminal,
#   used to divide long sections into smaller pieces.
# Arguments:
#   A message to print
#######################################
tstyle_subsection() {
  _tstyle_before_hook tstyle_subsection "$@"
  local text="$1"
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")
  printf "%b\n" "${padding}${_TS_SUBSECTION_TEXT_STYLE}${text}${_TS_RESET}"
  _tstyle_after_hook tstyle_subsection "$@"
}

#######################################
# Print "step" to the terminal,
#   used to display actions in the terminal, e.g. running a command.
# Arguments:
#   A message to print
#######################################
tstyle_step() {
  _tstyle_before_hook tstyle_step "$@"
  local text="$1"
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")
  printf "%b\n" "${padding}${_TS_STEP_BULLET_STYLE}${_TS_STEP_BULLET_CHAR}${_TS_RESET}${_TS_STEP_TEXT_STYLE}${text}${_TS_RESET}"
  _tstyle_after_hook tstyle_step "$@"
}

#######################################
# Print "step" to the terminal but with progress,
#   used to display actions in the terminal, e.g. running a command.
#   This function is different in that it can show "status" when running
#   multiple steps and max number of steps is known.
# Arguments:
#   Current step
#   Max steps
#   A message to print
#######################################
tstyle_pstep() {
  _tstyle_before_hook tstyle_pstep "$@"
  local current_step="$1"
  local max_steps="$2"
  local text="$3"
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")
  local bar_str=$(printf "${_TS_PSTEP_BAR_LEFT}%2s/%-2s${_TS_PSTEP_BAR_RIGHT}" "$current_step" "$max_steps")
  printf "%b\n" "${padding}${bar_str}${_TS_PSTEP_BULLET_STYLE}${_TS_PSTEP_BULLET_CHAR}${_TS_RESET}${_TS_PSTEP_TEXT_STYLE}${text}${_TS_RESET}"
  _tstyle_after_hook tstyle_pstep "$@"
}

#######################################
# Print "substep" for when you need another stair of steps.
# Arguments:
#   A message to print
#######################################
tstyle_substep() {
  _tstyle_before_hook tstyle_substep "$@"
  local text="$1"
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")
  printf "%b\n" "${padding}${_TS_SUBSTEP_BULLET_STYLE}${_TS_SUBSTEP_BULLET_CHAR}${_TS_RESET}${_TS_SUBSTEP_TEXT_STYLE}${text}${_TS_RESET}"
  _tstyle_after_hook tstyle_substep "$@"
}

#######################################
# Print "INFO" message to the terminal.
# Arguments:
#   A message to print
#######################################
tstyle_info() {
  _tstyle_before_hook tstyle_info "$@"
  local text="$1"
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")
  printf "%b\n" "${padding}${_TS_LOG_INFO} ${_TS_LOG_TEXT_STYLE}${text}${_TS_RESET}"
  _tstyle_after_hook tstyle_info "$@"
}

#######################################
# Print "OK" message to the terminal.
# Arguments:
#   A message to print
#######################################
tstyle_ok() {
  _tstyle_before_hook tstyle_ok "$@"
  local text="$1"
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")
  printf "%b\n" "${padding}${_TS_LOG_OK} ${_TS_LOG_TEXT_STYLE}${text}${_TS_RESET}"
  _tstyle_after_hook tstyle_ok "$@"
}

#######################################
# Print "SUCCESS" message to the terminal.
# Arguments:
#   A message to print
#######################################
tstyle_success() {
  _tstyle_before_hook tstyle_success "$@"
  local text="$1"
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")
  printf "%b\n" "${padding}${_TS_LOG_SUCCESS} ${_TS_LOG_TEXT_STYLE}${text}${_TS_RESET}"
  _tstyle_after_hook tstyle_success "$@"
}

#######################################
# Print "WARNING" message to the terminal.
# Arguments:
#   A message to print
#######################################
tstyle_warn() {
  _tstyle_before_hook tstyle_warn "$@"
  local text="$1"
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")
  printf "%b\n" "${padding}${_TS_LOG_WARN} ${_TS_LOG_TEXT_STYLE}${text}${_TS_RESET}"
  _tstyle_after_hook tstyle_warn "$@"
}

#######################################
# Print "ERROR" message to the terminal.
# Arguments:
#   A message to print
#######################################
tstyle_error() {
  _tstyle_before_hook tstyle_error "$@"
  local text="$1"
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")
  printf "%b\n" "${padding}${_TS_LOG_ERROR} ${_TS_LOG_TEXT_STYLE}${text}${_TS_RESET}"
  _tstyle_after_hook tstyle_error "$@"
}

#######################################
# Print unordered list to the terminal.
# Arguments:
#   Array with items to print
#######################################
tstyle_ul() {
  if [[ "$#" -eq 0 ]]; then return; fi
  _tstyle_before_hook tstyle_ul "$@"

  local item
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")

  for item in "$@"; do
    printf "%b\n" "${padding}${_TS_UL_BULLET_STYLE}${_TS_UL_TEXT_STYLE}${item}${_TS_RESET}"
  done
  _tstyle_after_hook tstyle_ul "$@"
}

#######################################
# Print ordered list to the terminal.
# Arguments:
#   Array with items to print
#######################################
tstyle_ol() {
  if [[ "$#" -eq 0 ]]; then return; fi
  _tstyle_before_hook tstyle_ol "$@"

  local i=1
  local item
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")

  for item in "$@"; do
    printf "%b${_TS_OL_BULLET_STYLE}%b\n" "${padding}" "$i" "${_TS_OL_TEXT_STYLE}${item}${_TS_RESET}"
    i=$((i + 1))
  done
  _tstyle_after_hook tstyle_ol "$@"
}

#######################################
# Print formatted code to the terminal
# Arguments:
#   Code to print
#######################################
tstyle_code() {
  _tstyle_before_hook tstyle_code "$@"
  local text="$1"
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")
  printf "%b\n" "${padding}${_TS_CODE_PROMPT_STYLE}\$${_TS_RESET} ${text}${_TS_RESET}"
  _tstyle_after_hook tstyle_code "$@"
}

#######################################
# Show the output of a command to the screen,
#   with max visible lines allowed.
# Arguments:
#   $1: title
#   STDIN: is the STDOUT of a command
#######################################
tstyle_output() {
  _tstyle_before_hook tstyle_output "$@"
  local title="$1"
  local title_len=${#title}

  # Make sure title is not too long
  if (( $title_len > $(($_TS_OUTPUT_WIDTH - 4)) )); then
    local truncated_text_len=$(($_TS_OUTPUT_WIDTH - 7))
    title="${title:0:$truncated_text_len}..."
    title_len=${#title}
  fi

  local title_padding_length=$(((($_TS_OUTPUT_WIDTH - title_len) / 2) - 2))
  local title_line_start="${_TS_OUTPUT_BORDER_CHARS[1]}"$(_tstyle_repeat_char $title_padding_length "${_TS_OUTPUT_BORDER_CHARS[0]}")
  local title_line_end=$(_tstyle_repeat_char $title_padding_length "${_TS_OUTPUT_BORDER_CHARS[0]}")
  local footer_padding_length=$(($_TS_OUTPUT_WIDTH - 2))
  local footer_line=${_TS_OUTPUT_BORDER_CHARS[3]}$(_tstyle_repeat_char $footer_padding_length "${_TS_OUTPUT_BORDER_CHARS[0]}")${_TS_OUTPUT_BORDER_CHARS[4]}
  local padding=$(_tstyle_repeat_char $_TS_PAD_LEVEL "$_TS_LEVEL_PAD_CHAR")

  # Handle odd length padding if necessary
  [[ $(((title_len + title_padding_length * 2) % 2)) -ne 0 ]] && title_line_end="$title_line_end${_TS_OUTPUT_BORDER_CHARS[0]}"
  title_line_end="$title_line_end${_TS_OUTPUT_BORDER_CHARS[2]}"
  
  local buffer=()

  printf '\e[s'
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Make sure line is not too long
    local line_len=${#line}
    if (( $line_len > $(($_TS_OUTPUT_WIDTH - 2)) )); then
      local truncated_line_len=$(($_TS_OUTPUT_WIDTH - 5))
      line="${line:0:$truncated_line_len}..."
      line_len=${#line}
    fi

    # Buffer last ($_TS_OUTPUT_HEIGHT - 2) lines (-2 for header and footer)
    buffer+=("$padding  $line")

    # Max height control
    if ((${#buffer[@]} > $(($_TS_OUTPUT_HEIGHT - 2)))); then
      buffer=("${buffer[@]:1}")
    fi

    printf '\e[u'
    printf '\e[J'
    printf '\e[s'
    printf "%b\n" "${padding}${_TS_OUTPUT_BORDER_STYLE}${title_line_start} ${title} ${title_line_end}${_TS_RESET}"

    for item in "${buffer[@]}"; do
      printf "%b\n" "$item"
    done
    
    local current_buffer_height=${#buffer[@]}
    for ((i=current_buffer_height; i < $(($_TS_OUTPUT_HEIGHT - 2)); i++)); do
      printf "\n"
    done

    printf "%b\n" "${padding}${_TS_OUTPUT_BORDER_STYLE}${footer_line}${_TS_RESET}"
  done
  _tstyle_after_hook tstyle_output "$@"
}

#######################################
# Execute the command, and print the
#   buffered output to the screen
# Arguments:
#   $@: command
#######################################
tstyle_exec() {
  _tstyle_before_hook tstyle_exec "$@"
  exec $@ | tstyle_output "$*"
  _tstyle_after_hook tstyle_exec "$@"
}
