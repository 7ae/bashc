#!/bin/bash

# Script: rename-video-track.sh
# Description: This script renames the video track name in an MKV file using mkvpropedit.
#
# Usage: ./rename-video-track.sh [track_name] [input] [output]
#
# Arguments:
#   track_name : (Optional) New name for the video track. Default is "Track 1".
#   input      : (Optional) Path to the input MKV file or directory.
#   output     : (Optional) Path to the output MKV file or directory.

# Function to display script usage
display_usage() {
    echo "Usage: $0 [track_name] [input] [output]"
}

# Check if the correct number of arguments (0 to 3) is provided or if the user asked for help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_usage
    exit 0
elif [ $# -lt 0 ] || [ $# -gt 3 ]; then
    display_usage
    exit 1
fi

# Default values if arguments are not provided
TRACK_NAME="${1:-Track 1}"
INPUT="${2:-./}"
OUTPUT="${3:-./}"

# Function to rename video track name
rename_video_track() {
    local input_file="$1"
    local output_file="$2"

    # Use mkvpropedit to modify the Video track name
    mkvpropedit "$input_file" --edit track:v1 --set name="$TRACK_NAME"
    echo "Video track name changed to \"$TRACK_NAME\" in $output_file"
}

# Check if input and output are files or directories
if [[ -f "$INPUT" ]]; then
    # Input is a file
    if [[ "${INPUT##*.}" == "mkv" ]]; then
        # Input is an MKV file
        if [[ -d "$OUTPUT" ]]; then
            # Output is a directory
            output_file="${OUTPUT%/}/${INPUT##*/}"
            rename_video_track "$INPUT" "$output_file"
        else
            # Output is a file or not provided
            if [[ "${OUTPUT##*.}" == "mkv" ]]; then
                # Output is an MKV file or not provided
                rename_video_track "$INPUT" "$OUTPUT"
            else
                echo "Invalid output file: $OUTPUT"
            fi
        fi
    else
        echo "Invalid input file: $INPUT"
    fi
elif [[ -d "$INPUT" ]]; then
    # Input is a directory
    if [[ -d "$OUTPUT" ]]; then
        # Output is a directory
        for input_file in "$INPUT"/*.mkv; do
            output_file="${OUTPUT%/}/${input_file##*/}"
            rename_video_track "$input_file" "$output_file"
        done
    else
        # Output is a file or not provided
        if [[ "${OUTPUT##*.}" == "mkv" ]]; then
            # Output is an MKV file or not provided
            for input_file in "$INPUT"/*.mkv; do
                rename_video_track "$input_file" "$OUTPUT"
            done
        else
            echo "Invalid output file: $OUTPUT"
        fi
    fi
else
    echo "Invalid input: $INPUT"
fi

