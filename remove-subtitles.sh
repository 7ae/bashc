#!/bin/bash

# Script: remove-subtitles.sh
# Description: This script removes all subtitle tracks from MKV files in a folder or a single MKV file.
# Usage: ./remove-subtitles.sh [input_path]
# Arguments:
#   input_path: (Optional) The path to the folder containing the MKV files or a single MKV file.

# Function to display script usage
display_usage() {
    echo "Usage: $0 [input_path]"
}

# Check if the correct number of arguments (0 or 1) is provided or if the user asked for help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_usage
    exit 0
elif [ $# -gt 1 ]; then
    display_usage
    exit 1
fi

# Get user input for the file or folder path
INPUT_PATH="${1:-./}"

# Use cd in a subshell to handle both relative and absolute paths correctly
(cd "$(dirname "$INPUT_PATH")" && cd ..) || { echo "Invalid input path."; exit 1; }

# Function to remove subtitles from a single MKV file
remove_subtitles_single_file() {
    local file="$1"

    # Check if the file is a regular file
    if [ -f "$file" ]; then
        # Temporarily store the subtitle tracks in a variable
        subtitle_tracks=$(mkvmerge -i "$file" | grep 'subtitles' | awk '{print $3}')

        # If there are subtitle tracks, remove them from the MKV file
        if [ -n "$subtitle_tracks" ]; then
            echo "Removing subtitles from: $file"
            mkvmerge -o "${file%.mkv}-no-subs.mkv" --no-subtitles "$file"
            rm "$file"  # Remove the original file
            mv "${file%.mkv}-no-subs.mkv" "$file"  # Rename the new file to the original name
        else
            echo "No subtitle tracks found in: $file"
        fi
    else
        echo "Invalid input file: $file"
    fi
}

# Function to remove subtitles from all MKV files in a folder
remove_subtitles_in_folder() {
    local folder="$1"

    # Check if the folder exists and is a directory
    if [ -d "$folder" ]; then
        # Loop through each file in the folder
        for file in "$folder"/*.mkv; do
            remove_subtitles_single_file "$file"
        done
    else
        echo "Invalid input folder: $folder"
    fi
}

# Check if the input path is a directory
if [ -d "$INPUT_PATH" ]; then
    remove_subtitles_in_folder "$INPUT_PATH"
elif [ -f "$INPUT_PATH" ]; then
    remove_subtitles_single_file "$INPUT_PATH"
else
    echo "Invalid input path. Please provide a valid file or folder path."
    exit 1
fi

echo "Subtitles removed successfully."

