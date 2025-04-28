# Custom Grep Implementation

A Bash script implementation of a grep-like command line tool that provides text pattern searching functionality with various options for customization.

## Features

- Case-insensitive pattern matching
- Line number display option (-n)
- Inverted match option (-v)
- Combined options support (-nv, -vn)
- Helpful usage information (--help)
- Also supported another version from help (-h)

## Installation

1. Clone this repository or download the script files
2. Make the script executable:
   ```bash
   chmod +x mygrep.sh
   ```

## Usage

```bash
./mygrep.sh [-n] [-v] search_string file
```

### Options

- `-n`: Print line numbers with matching lines
- `-v`: Invert match (print non-matching lines)
- `-nv` or `-vn`: Combine both options (print line numbers with non-matching lines)
- `-h` or `--help`: Display help message

### Examples

1. Basic search:
   ```bash
   ./mygrep.sh "test" file.txt
   ```

2. Search with line numbers:
   ```bash
   ./mygrep.sh -n "test" file.txt
   ```

3. Inverted match:
   ```bash
   ./mygrep.sh -v "test" file.txt
   ```

4. Combined options:
   ```bash
   ./mygrep.sh -nv "test" file.txt
   ```

## Testing



## Implementation Details

- Uses native grep command with custom option handling
- Implements getopts for robust command-line argument parsing
- Provides user-friendly error messages and usage information
- Maintains case-insensitive searching by default

## Error Handling

The script handles various error cases:
- Missing search string or file
- Non-existent input files
- Invalid command options
