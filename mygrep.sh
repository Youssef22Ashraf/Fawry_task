#!/bin/bash

# Help function
usage() {
    echo "Usage: $0 [-n] [-v] [-E] [-c] [-l] search_string file"
    echo "Options:"
    echo "  -n    Print line numbers with matching lines"
    echo "  -v    Invert match (print non-matching lines)"
    echo "  -E    Interpret PATTERN as an extended regular expression (ERE)"
    echo "  -c    Print only a count of matching lines"
    echo "  -l    Print only the names of files containing matches"
    echo "  --help Display this help message"
    echo "  -h    Display this help message"
    exit 1
}

# Initialize variables for options
line_numbers=0
invert=0
use_ere=0
count_lines=0
list_files=0

# Parse options using getopts
# Added E, c, l to the options string
while getopts "nvEcl" opt; do
    case $opt in
        n) line_numbers=1 ;;
        v) invert=1 ;;
        E) use_ere=1 ;; # Set flag for extended regex
        c) count_lines=1 ;; # Set flag for count
        l) list_files=1 ;; # Set flag for list files
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    esac
done

# Check for --help flag
if [[ "$1" == "--help" ]]; then
    usage
fi

# Shift past options to get search string and file
shift $((OPTIND - 1))

# Validate arguments
if [ $# -lt 2 ]; then
    echo "Error: Missing search string or file" >&2
    usage
fi

search_string="$1"
file="$2"

# Check if file exists
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found" >&2
    exit 1
fi

# Build grep options
grep_opts="-i" # Start with case-insensitive matching

if [ "$line_numbers" = 1 ]; then
    grep_opts="${grep_opts}n" # Add -n for line numbers
fi

if [ "$invert" = 1 ]; then
    grep_opts="${grep_opts}v" # Add -v for invert match
fi

# Add new options to the grep command string
if [ "$use_ere" = 1 ]; then
    grep_opts="${grep_opts}E" # Add -E for extended regex
fi

if [ "$count_lines" = 1 ]; then
    grep_opts="${grep_opts}c" # Add -c for count
fi

if [ "$list_files" = 1 ]; then
    grep_opts="${grep_opts}l" # Add -l for list files
fi

# Execute grep with the constructed options
grep "$grep_opts" "$search_string" "$file"