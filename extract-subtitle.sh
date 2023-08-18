#!/bin/bash

# Script: extract-subtitle.sh
# Description: This script extracts the subtitle track from an MKV file and saves it as an SRT file.
#              The user can specify the input file or folder path, subtitle track number,
#              and output file or folder path as command-line arguments. If the subtitle track number
#              is not provided, the script will use 2 as the default.
#
# Usage: ./extract-subtitle.sh input_path [subtitle_track_number] [output_path]
#
# Arguments:
#   input_path            : The path to the MKV file or folder containing MKV files.
#   subtitle_track_number : (Optional) The number of the subtitle track to extract (default is 2 if not provided).
#   output_path           : (Optional) The path to the folder where the extracted subtitle tracks
#                           will be saved or the path to the output SRT file.

# Function to display script usage
display_usage() {
    echo "Usage: $0 input_path [subtitle_track_number] [output_path]"
}

# Function to extract subtitle track from an MKV file
extract_subtitle_track() {
    local input_file="$1"
    local output_file="$2"

    # Use mkvextract to extract the selected subtitle track
    mkvextract tracks "$input_file" "$SUBTITLE_TRACK_NUMBER:$output_file"
    echo "Subtitle track $SUBTITLE_TRACK_NUMBER extracted from $input_file and saved as $output_file"
}

# Check if the correct number of arguments (1 to 3) is provided or if the user asked for help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_usage
    exit 0
elif [ $# -lt 1 ] || [ $# -gt 3 ]; then
    display_usage
    exit 1
fi

INPUT="$1"
SUBTITLE_TRACK_NUMBER="${2:-2}"
OUTPUT="${3:-}"

# Check if the input file or folder exists
if [[ ! -e "$INPUT" ]]; then
    echo "Invalid input path: $INPUT"
    exit 1
fi

# Set the default output folder to the input folder if not provided
if [[ -z "$OUTPUT" ]]; then
    OUTPUT="$INPUT"
fi

# Check if the output path exists, if not, create it
mkdir -p "$OUTPUT"

# Check if the input is a file
if [[ -f "$INPUT" ]]; then
    # Input is a file
    if [[ "${INPUT##*.}" == "mkv" ]]; then
        # Input is an MKV file
        if [[ -d "$OUTPUT" ]]; then
            # Output is a directory
            output_file="${OUTPUT%/}/${INPUT##*/}"
            output_file="${output_file%.*}.srt"
            extract_subtitle_track "$INPUT" "$output_file"
        else
            # Output is a file
            if [[ "${OUTPUT##*.}" == "srt" ]]; then
                extract_subtitle_track "$INPUT" "$OUTPUT"
            else
                echo "Invalid output file: $OUTPUT"
                exit 1
            fi
        fi
    else
        echo "Invalid input file: $INPUT"
        exit 1
    fi
elif [[ -d "$INPUT" ]]; then
    # Input is a directory
    if [[ -d "$OUTPUT" ]]; then
        # Output is a directory
        for input_file in "$INPUT"/*.mkv; do
            output_file="${OUTPUT%/}/${input_file##*/}"
            output_file="${output_file%.*}.srt"
            extract_subtitle_track "$input_file" "$output_file"
        done
    else
        # Output is a file
        if [[ "${OUTPUT##*.}" == "srt" ]]; then
            for input_file in "$INPUT"/*.mkv; do
                extract_subtitle_track "$input_file" "$OUTPUT"
            done
        else
            echo "Invalid output file: $OUTPUT"
            exit 1
        fi
    fi
fi

