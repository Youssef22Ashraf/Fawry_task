# Custom Grep Implementation

A Bash script implementation of a grep-like command line tool that provides text pattern searching functionality with various options for customization.

## Features

- Case-insensitive pattern matching
- Line number display option (-n)
- Inverted match option (-v)
- Extended Regular Expression support (-E)
- Count matching lines option (-c)
- List filenames with matches option (-l)
- Combined options support (-nv, -vn, etc.)
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
./mygrep.sh [-n] [-v] [-E] [-c] [-l] search_string file
```

### Options

- `-n`: Print line numbers with matching lines
- `-v`: Invert match (print non-matching lines)
- `-E`: Interpret PATTERN as an extended regular expression (ERE)
- `-c`: Print only a count of matching lines
- `-l`: Print only the names of files containing matches
- `-nv` or `-vn`: Combine options (e.g., print line numbers with non-matching lines)
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

5. Count matching lines:
   ```bash
   ./mygrep.sh -c "test" file.txt
   ```

6. List files containing matches:
   ```bash
   ./mygrep.sh -l "test" *.txt
   ```

7. Extended Regular Expression search:
   ```bash
   ./mygrep.sh -E 'hello|test' file.txt
   ```

## Testing

To validate the functionality of `mygrep.sh`, create a test file named `testfile.txt` with the following content:

```text
Hello world
This is a test
another test line
HELLO AGAIN
Don't match this line
Testing one two three
```

Run the following test commands and verify the outputs:

1. **Basic search**:
   ```bash
   ./mygrep.sh hello testfile.txt
   ```
   **Expected Output**:
   ```
   Hello world
   HELLO AGAIN
   ```

2. **Search with line numbers**:
   ```bash
   ./mygrep.sh -n hello testfile.txt
   ```
   **Expected Output**:
   ```
   1:Hello world
   4:HELLO AGAIN
   ```

3. **Inverted match with line numbers**:
   ```bash
   ./mygrep.sh -vn hello testfile.txt
   ```
   **Expected Output**:
   ```
   2:This is a test
   3:another test line
   5:Don't match this line
   6:Testing one two three
   ```

4. **Error handling (missing search string)**:
   ```bash
   ./mygrep.sh -v testfile.txt
   ```
   **Expected Output**:
   ```
   Error: Missing search string or file
   Usage: ./mygrep.sh [-n] [-v] [-E] [-c] [-l] search_string file
   Options:
     -n    Print line numbers with matching lines
     -v    Invert match (print non-matching lines)
     -E    Interpret PATTERN as an extended regular expression (ERE)
     -c    Print only a count of matching lines
     -l    Print only the names of files containing matches
     --help Display this help message
   ```

5. **Help message**:
   ```bash
   ./mygrep.sh --help
   ```
   **Expected Output**:
   ```
   Usage: ./mygrep.sh [-n] [-v] [-E] [-c] [-l] search_string file
   Options:
     -n    Print line numbers with matching lines
     -v    Invert match (print non-matching lines)
     -E    Interpret PATTERN as an extended regular expression (ERE)
     -c    Print only a count of matching lines
     -l    Print only the names of files containing matches
     --help Display this help message
   ```

For additional options (`-E`, `-c`, `-l`), create test files with relevant content and run commands like:
```bash
./mygrep.sh -E 'hello|test' testfile.txt
./mygrep.sh -c "test" testfile.txt
./mygrep.sh -l "test" *.txt
```

## Implementation Details

- Uses `awk` for efficient line-by-line text processing and pattern matching
- Implements `getopts` for robust command-line argument parsing
- Provides user-friendly error messages and usage information
- Maintains case-insensitive searching by default

## Error Handling

The script handles various error cases:
- Missing search string or file
- Non-existent input files
- Invalid command options
