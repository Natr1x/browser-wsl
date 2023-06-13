# WSL Open Tool

The WSL Open Tool is a bash script intended for use in Ubuntu WSL. This script
allows you to open a file or link in your host browser from within the WSL
environment.

## Requirements

- Ubuntu on Windows Subsystem for Linux (WSL)

## Usage

You can use this script by calling it and providing a file or link as a
parameter. You can also provide some options to customize the behavior of the
script.

Here is the basic usage:

```bash
/path/to/browser-wsl/browser-wsl.sh [OPTION] LINK/FILE
```

### Parameters

- `LINK/FILE`: A web link or file path to open. WSL paths are automatically
  translated to Windows paths. The link will be opened with the command
  specified in `BROWSER` environment variable unless a different program is
  specified with `-E|--engine`.

### Options

- `-h`: Display help message and does not run the rest of the script.
- `-v|--verbose`: Enable verbose output using 'set -x'.
- `-E|--engine`: Specify a different web browser than specified in `BROWSER`.

### Environment Variables

- `BROWSER`: The browser to use if `-E|--engine` is not specified.
- `LOG_LEVEL`: Use to set debug log level for prints. Set to 0 for none. Default is 1.

## Example

To open a link in your default browser, you would use:

```bash
/path/to/browser-wsl/browser-wsl.sh https://www.example.com
```

To open a file in your default browser, you would use:

```bash
/path/to/browser-wsl/browser-wsl.sh /path/to/file.html
```

To open a link in a specific browser (e.g., Firefox), you would use:

```bash
BROWSER=firefox /path/to/browser-wsl/browser-wsl.sh https://www.example.com
```

## Logging

The script provides colorful logging for different levels of messages,
including error, warning, info, and data input. The colors can be adjusted by
modifying the script.

