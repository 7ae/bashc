#!/bin/bash

# Script: download-files.sh
# Description: This script downloads files from a URL that match a specific filename pattern
#              and saves them in the specified output folder. The script also allows excluding
#              files based on a pattern if the user provides an exclude pattern.
#
# Usage: ./download-files.sh filename_pattern url [out_path] [exclude_pattern]
#
# Arguments:
#   filename_pattern : The filename pattern (can include wildcard *) to match the files to download.
#   url              : The URL from which to download the files.
#   out_path         : (Optional) The path to the folder where the downloaded files will be saved.
#                      If not provided, the current folder will be used as the default.
#   exclude_pattern  : (Optional) The pattern to exclude files from download. If provided, files
#                      with filenames matching this pattern will be skipped.

# Function to display script usage
display_usage() {
    echo "Usage: $0 filename_pattern url [out_path] [exclude_pattern]"
}

# Check if the correct number of arguments (2 to 4) is provided or if the user asked for help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_usage
    exit 0
elif [ $# -lt 2 ] || [ $# -gt 4 ]; then
    display_usage
    exit 1
fi

# Get user input for filename_pattern, url, out_path, and exclude_pattern
FILENAME_PATTERN="$1"
URL="$2"
OUT_PATH="${3:-./}"
EXCLUDE_PATTERN="${4:-}"

# Ensure that the exclude_pattern has the correct format
if [ -n "$EXCLUDE_PATTERN" ]; then
    # Check if the exclude_pattern starts with "*"
    if [[ "$EXCLUDE_PATTERN" != "*"* ]]; then
        EXCLUDE_PATTERN="*$EXCLUDE_PATTERN"
    fi
    # Check if the exclude_pattern ends with "*"
    if [[ "$EXCLUDE_PATTERN" != *"*" ]]; then
        EXCLUDE_PATTERN="$EXCLUDE_PATTERN*"
    fi
fi

# Create the output folder if it doesn't exist
mkdir -p "$OUT_PATH"

# Use wget to download files matching the filename_pattern from the URL
wget -nd -P "$OUT_PATH" -r --no-parent -A "$FILENAME_PATTERN" -R "$EXCLUDE_PATTERN" "$URL"

echo "Files downloaded successfully to $OUT_PATH"

