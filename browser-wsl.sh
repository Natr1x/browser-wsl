#!/bin/bash

browser_cmd="$BROWSER"
tool_path="$0"
LOG_LEVEL="${LOG_LEVEL:="1"}"

function show_help {
cat << EOF
Usage: $tool_path [OPTION] LINK/FILE
Open a file or link in host browser from wsl.

LINK/FILE:
  A weblink or file path to open. Wsl paths are automatically translated to
  windows paths. The link will be opened with the cmd specified in $$BROWSER
  unless a different program is specified with -E|--engine.

Options:
  -h|--help     Display this help message, do not run the rest of the script.
  -v|--verbose  Use 'set -x' to for verbose output.
  -E|--engine   Specify a different webbrowser than specified in $$BROWSER.

Environment Variables:
  BROWSER   The browser to use unless if '-E|--engine' is not specified.
  LOG_LEVEL Use to set debug log level for prints. Set to 0 for none. Default is 1.

EOF
}


## color
black=$(echo -e '\e[30m')
red=$(echo -e '\e[31m')
green=$(echo -e '\e[32m')
brown=$(echo -e '\e[33m')
blue=$(echo -e '\e[34m')
purple=$(echo -e '\e[35m')
cyan=$(echo -e '\e[36m')
yellow=$(echo -e '\e[33m')
white=$(echo -e '\e[37m')
dark_gray=$(echo -e '\e[1;30m')
light_red=$(echo -e '\e[1;31m')
light_green=$(echo -e '\e[1;32m')
light_blue=$(echo -e '\e[1;34m')
light_purple=$(echo -e '\e[1;35m')
light_cyan=$(echo -e '\e[1;36m')
light_gray=$(echo -e '\e[37m')
orange=$(echo -e '\e[38;5;202m')
light_orange=$(echo -e '\e[38;5;214m')
deep_purple=$(echo -e '\e[38;5;140m')
bold=$(echo -e '\033[1m')
reset=$(echo -e '\033(B\033[m')

## indicator
error_log_tag="${red}[error:$tool_path]${reset}"
warn_log_tag="${orange}[warn:$tool_path]${reset}"
info_log_tag="${green}[info:$tool_path]${reset}"
data_log_tag="${cyan}[input:$tool_path]${reset}"

# echo functions
function log {
    local log_tag="$info_log_tag"
    local log_level=$1

    case "$1" in
        1) log_tag="$error_log_tag"; shift;;
        2) log_tag="$warn_log_tag"; shift ;;
        3) log_tag="$info_log_tag"; shift ;;
        4|5|6|7|8|9) log_tag="$data_log_tag"; shift ;;
        *)
            echo "$error_log_tag The log function needs a valid log level"
            exit 128
            ;;
    esac

    if [ "$LOG_LEVEL" -ge "$log_level" ]; then
        echo -n "$log_tag "
        echo "$@"
    fi
}

function log_err {
    log 1 "$@"
}

function log_warn {
    log 2 "$@"
}

function log_info {
    log 3 "$@"
}

function log_data {
    log 4 "$@"
}

function handle_args {
    while [ "$1" != "" ]; do
        log_info "Processing arguments: '$1' '$2'"
        case "$1" in

            -v|--verbose)
                tool_debug=${tool_debug:="--verbose"};
                if [ "$tool_debug" == "--verbose" ]; then
                    echo "[$tool_path] Showing verbose output." 1>&2
                    set -x
                fi
                shift;;

            -h|--help)
                show_help;
                exit;;

            -E|--engine)
                shift
                log_info "Using '$1' as browser program"
                browser_cmd="$1"
                shift;;

            --)
                shift
                lname="$*";
                return;;
        esac
    done
}

options=$(getopt -u -l "verbose,help,engine:" -o "vhE:" -- "$@")
handle_args $options

function url_validator {
     content=$(curl --head --silent "$*" | head -n 1)
     if [ -n "$content" ]; then
         return 0
     else
         return 1
     fi
}

if [[ "$lname" != "" ]]; then

    # file:/// protocol used in linux
    if [[ "$lname" =~ ^file:\/\/.*$ ]] && [[ ! "$lname" =~ ^file:\/\/(\/)+[A-Za-z]\:.*$ ]]; then
        log_info "Received file:/// protocol used in linux"
        properfile_full_path="$(readlink -f "${lname//file:\/\//}")"

    # Linux absolute path
    elif [[ "$lname" =~ ^(/[^/]+)*(/)?$ ]]; then
        log_info "Received linux absolute path"
        properfile_full_path="$(readlink -f "${lname}")"

    # Linux relative path
    elif [[ -d "$(readlink -f "$lname")" ]] || [[ -f "$(readlink -f "$lname")" ]]; then
        log_info "Received linux relative path"
        properfile_full_path="$(readlink -f "${lname}")"
    fi

    log_info "properfile_full_path: $properfile_full_path"
    log_info "validating whether if it is a link"

    if [ ! -e "$properfile_full_path" ] && (url_validator "$lname") ; then
        log_info "It is a link"
        path="\"$lname\""

    elif [[ "$lname" =~ ^file:\/\/(\/)+[A-Za-z]\:.*$ ]] || [[ "$lname" =~ ^[A-Za-z]\:.*$ ]]; then
        log_info "It is not a link; received windows absolute path/file protocol windows absolute path"
        path="\"$lname\""

    else
        log_info "It is not a link"
        path="$(wslpath -w "${properfile_full_path:-$lname}" 2>/dev/null || echo "$lname")"
    fi

    log_info "browser: '$browser_cmd' path: '$path'"
    "$browser_cmd" "$path"
else
    log_err "No input, aborting"
    exit 21
fi
