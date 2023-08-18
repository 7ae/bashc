#!/bin/bash

# Script: switch-audio-track.sh
# Description: This script extracts audio tracks from MKV video files, reorders them, and optionally sets custom audio track names.
#
# Usage: ./switch-audio-track.sh [audio_name_1] [audio_name_2] [input_folder] [output_folder]
#
# Arguments:
#   audio_name_1 : (Optional) Custom name for the first audio track.
#   audio_name_2 : (Optional) Custom name for the second audio track.
#   input_folder : (Optional) Path to the input folder containing MKV files (default: current folder).
#   output_folder: (Optional) Path to the output folder where processed files will be saved (default: current folder).

# Store provided arguments
AUDIO_NAME_1="${1:-}"
AUDIO_NAME_2="${2:-}"
INPUT_FOLDER="${3:-./}"
OUTPUT_FOLDER="${4:-./}"

# Use cd in a subshell to handle both relative and absolute paths correctly
(cd "$INPUT_FOLDER" && cd ..) || { echo "Invalid input folder path."; exit 1; }

# Create the output folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"

# Loop through each file in the input folder with .mkv extension
for FILE in "$INPUT_FOLDER"/*.mkv; do
  # Check if the file is a regular file
  if [ -f "$FILE" ]; then
    # Extract the video and audio tracks using mkvextract
    mkvextract tracks "$FILE" 0:"${OUTPUT_FOLDER}/${FILE##*/}-video.h264" 1:"${OUTPUT_FOLDER}/${FILE##*/}-audio1.ogg" 2:"${OUTPUT_FOLDER}/${FILE##*/}-audio2.ogg"
    
    # Create a new MKV file with the desired audio track order using mkvmerge
    mkvmerge -o "${OUTPUT_FOLDER}/${FILE##*/}-output.mkv" "${OUTPUT_FOLDER}/${FILE##*/}-video.h264" "${OUTPUT_FOLDER}/${FILE##*/}-audio2.ogg" "${OUTPUT_FOLDER}/${FILE##*/}-audio1.ogg"
    
    # Set audio track names using mkvpropedit if they are provided
    if [ -n "$AUDIO_NAME_1" ] && [ -n "$AUDIO_NAME_2" ]; then
      mkvpropedit "${OUTPUT_FOLDER}/${FILE##*/}-output.mkv" --edit track:a1 --set name="$AUDIO_NAME_1" --edit track:a2 --set name="$AUDIO_NAME_2"
    fi
    
    # Optional: Clean up the extracted tracks
    rm "${OUTPUT_FOLDER}/${FILE##*/}-video.h264" "${OUTPUT_FOLDER}/${FILE##*/}-audio1.ogg" "${OUTPUT_FOLDER}/${FILE##*/}-audio2.ogg"
  fi
done

echo "MKV files processed successfully."

