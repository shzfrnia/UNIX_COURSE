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
    rm -rf --$mktemp_name;
    trap - EXIT
    exit_with_error "User kill process."
}

[ -z "$1" ] && exit_with_error 'First arguments must be src file name'
if [ -f "$1" ]; then
    :
else 
    exit_with_error "File '$1' not found"
fi
src_file_name=$1

executable_file_name="runME"

echo "Create temporary folder..."
mktemp_name=$(mktemp -d -t buildermetafilesXXX) || { exit_with_error "Failed crate temporary file."; }
succeful_message "Succeful."

trap handle_SIGNALS EXIT HUP INT QUIT PIPE TERM

echo "Copying src to temporary file..."
cp $src_file_name $mktemp_name
succeful_message "Succeful."

echo "Build src file..."
path_to_copy="$mktemp_name/$src_file_name"
g++ -o $executable_file_name $path_to_copy 2>/dev/null || { exit_with_error "Failed compiling src file."; }
succeful_message "Succeful."

echo "Remove temporary folder..."
rm -rf $mktemp_name
succeful_message "Succeful."