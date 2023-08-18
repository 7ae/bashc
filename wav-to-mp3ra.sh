#!/bin/bash

# Script: wav-to-mp3ra.sh
# Description: This script converts WAV audio files to both MP3 and RA formats using FFmpeg.
#
# Usage: ./wav-to-mp3ra.sh input_wav_file [input_wav_file ...]
#
# Arguments:
#   input_wav_file : Path to the input WAV audio file(s) you want to convert.

# Check if FFmpeg is installed
if ! command -v ffmpeg &>/dev/null; then
    echo "FFmpeg is not installed. Please install FFmpeg first."
    exit 1
fi

# Function to convert WAV to MP3
convert_to_mp3() {
    local input_file="$1"
    local output_file="${input_file%.*}.mp3"
    ffmpeg -i "$input_file" -codec:a libmp3lame -qscale:a 2 "$output_file"
    echo "Converted $input_file to $output_file (MP3)"
}

# Function to convert WAV to RA
convert_to_ra() {
    local input_file="$1"
    local output_file="${input_file%.*}.ra"
    ffmpeg -i "$input_file" -codec:a real_144 "$output_file"
    echo "Converted $input_file to $output_file (RA)"
}

# Main script starts here
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Script: wav-to-mp3ra.sh"
    echo "Description: This script converts WAV audio files to both MP3 and RA formats using FFmpeg."
    echo ""
    echo "Usage: ./wav-to-mp3ra.sh input_wav_file [input_wav_file ...]"
    echo ""
    echo "Arguments:"
    echo "  input_wav_file : Path to the input WAV audio file(s) you want to convert."
    exit 0
elif [ $# -eq 0 ]; then
    echo "Usage: $0 input_wav_file [input_wav_file ...]"
    exit 1
fi

for input_file in "$@"; do
    if [ ! -f "$input_file" ]; then
        echo "File not found: $input_file"
        continue
    fi

    convert_to_mp3 "$input_file"
    convert_to_ra "$input_file"
done

