#!/bin/bash

# Script: rename-files.sh
# Description: This script renames files in a folder by cutting off text after a specific target
#              at the Nth occurrence. The user can provide the text target, Nth occurrence, and
#              output path as command-line arguments. If the Nth occurrence or output path is not
#              provided, appropriate default values are used. The script renames the files in place
#              without creating duplicates.
#
# Usage: ./rename-files.sh input_path text_target [Nth_occurrence] [output_path]
#
# Arguments:
#   input_path       : The path to the file or folder containing the files you want to rename.
#   text_target      : The specific text you want to target for renaming.
#   Nth_occurrence   : (Optional) The occurrence number after which you want to cut off the text.
#                      If not provided, it is automatically set to 1.
#   output_path      : (Optional) The path to the folder where the renamed files will be saved.
#                      If not provided, the input folder will be used as the default.

# Function to display script usage
display_usage() {
    echo "Usage: $0 input_path text_target [Nth_occurrence] [output_path]"
}

# Check if the correct number of arguments (2 to 4) is provided or if the user asked for help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_usage
    exit 0
elif [ $# -lt 2 ] || [ $# -gt 4 ]; then
    display_usage
    exit 1
fi

# Set default values for Nth_occurrence and output_path if not provided
NTH_OCCURRENCE="${3:-1}"
OUTPUT_PATH="${4:-$1}"

# Get user input for the file or folder path, text target, and output path
INPUT_PATH="$1"
TEXT_TARGET="$2"

# Use cd in a subshell to handle both relative and absolute paths correctly
(cd "$(dirname "$INPUT_PATH")" && cd ..) || { echo "Invalid input path."; exit 1; }

# Function to rename a single file
rename_file() {
    local file="$1"
    local text_target="$2"
    local nth_occurrence="$3"
    local output_path="$4"

    # Get the filename without the path
    local filename=$(basename "$file")

    # Get the portion of the filename before the text target at the Nth occurrence
    local new_name=$(echo "$filename" | awk -F "$text_target" -v nth="$nth_occurrence" '{
        n = nth;
        idx = 0;
        for (i = 1; i <= NF; i++) {
            if ($i == "") {
                continue;
            }
            idx++;
            if (idx == n) {
                break;
            }
        }
        for (j = 1; j <= idx; j++) {
            printf("%s", $j);
            if (j < idx) {
                printf("%s", FS);
            }
        }
    }')

    # Get the file extension
    local extension="${filename##*.}"

    # Check if the new filename already exists
    if [ -e "$output_path/$new_name.$extension" ]; then
        echo "Skipping $file. New filename already exists."
    else
        # Rename the file and move it to the output path
        mv "$file" "$output_path/$new_name.$extension"
    fi
}

# Check if the input path is a directory
if [ -d "$INPUT_PATH" ]; then
    # Loop through each file in the input directory
    for file in "$INPUT_PATH"/*; do
        # Check if the file is a regular file
        if [ -f "$file" ]; then
            rename_file "$file" "$TEXT_TARGET" "$NTH_OCCURRENCE" "$OUTPUT_PATH"
        fi
    done
else
    # Check if the input path is a file
    if [ -f "$INPUT_PATH" ]; then
        rename_file "$INPUT_PATH" "$TEXT_TARGET" "$NTH_OCCURRENCE" "$OUTPUT_PATH"
    else
        echo "Invalid input path. Please provide a valid file or folder path."
        exit 1
    fi
fi

echo "Files renamed successfully."

