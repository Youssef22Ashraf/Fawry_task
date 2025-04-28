#!/bin/bash

# Help function
usage() {
    echo "Usage: $0 [-n] [-v] search_string file"
    echo "Options:"
    echo "  -n     Print line numbers with matching lines"
    echo "  -v     Invert match (print non-matching lines)"
    echo "  -nv    Invert match and print line numbers"
    echo "  -vn    Invert match and print line numbers"
    echo "  -h     Display this help message"
    echo "  --help Display this help message (common way)"
    echo "Example: $0 -n test file.txt"
    exit 1
}

# Parse options using getopts
while getopts "nv" opt; do
    case $opt in
        n) line_numbers=1 ;;
        v) invert=1 ;;
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

# Execute grep with the constructed options
grep "$grep_opts" "$search_string" "$file"