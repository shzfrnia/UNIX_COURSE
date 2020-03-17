#!/bin/bash -e

function exit_with_error() {
    BIGWHITETEXT="\033[1;37m"
    BGRED='\033[41m'
    NORMAL="\033[0m"
    echo ""
    printf "${BIGWHITETEXT}${BGRED} %s ${NORMAL}" $1;
    echo ""
    exit 1;
}

function succeful_message() {
    BLACK="\033[30m"
    GREEN='\033[0;32m'
    NORMAL="\033[0m"
    BGGREEN="\033[42m"
    printf "${GREEN} *** %s ${NORMAL}\n" $1
}

function handle_SIGNALS() {
    rm -rf -- $mktemp_name;
    exit_with_error "User kill process. Temporary folder was removed."
}

[ -z "$1" ] && exit_with_error 'First arguments must be src file name'
if [ -f "$1" ]; then
  :
else 
  exit_with_error "File '$1' not found"
fi

src_file_name="$1"
OUTPUT_NAME_REGEX="s/^[[:space:]]*\/\/[[:space:]]*Output[[:space:]]*\([^ ]*\)$/\1/p"

executable_file_name=$(sed -n -e "$OUTPUT_NAME_REGEX" "$src_file_name" | grep -m 1 "")
if [$executable_file_name == ""] 
then
  exit_with_error "Output name is not found '$src_file_name'."
fi

echo "Create temporary folder..."
mktemp_name=$(mktemp -d -t buildermetafilesXXX) || { exit_with_error "Failed crate temporary file."; }
succeful_message "Succeful."

trap handle_SIGNALS HUP INT QUIT PIPE TERM

echo "Copying src to temporary file..."
cp "$src_file_name" $mktemp_name
succeful_message "Succeful."

echo "Build src file..."
path_to_copy="$mktemp_name/$src_file_name"
current_path=$(pwd)
cd "$mktemp_name" \
  && g++ -o "$executable_file_name" "$src_file_name" \
  || { exit_with_error "Failed compiling src file."; }
succeful_message "Succeful."

echo "Move executable file to current path..."
mv "$executable_file_name" "$current_path"
succeful_message "Succeful."

echo "Remove temporary folder..."
rm -rf -- "$mktemp_name"
succeful_message "Succeful."