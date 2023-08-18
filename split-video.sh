#!/bin/bash

# Script: split-video.sh
# Description: This script divides an MKV or MP4 video file into multiple segments.
#              The user can specify the input file path and the number of segments
#              as command-line arguments. The script will then divide the video
#              evenly into the specified number of segments. The user can also
#              optionally specify the output folder where the segments will be saved.
#              If no output folder is provided, the segments will be saved in the
#              same folder as the input file.

# Usage: ./split-video.sh <input_file> [num_segments]
#
# Arguments:
#   input_file   : The path to the input video file (MKV or MP4) to be divided into segments.
#   num_segments : (Optional) The number of segments to divide the video into. If not provided,
#                  the default value is 2.

# Check if the correct number of arguments (1 or 2) is provided
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 <input_file> [num_segments]"
    exit 1
fi

input_file="$1"
num_segments="${2:-2}"

# Get the absolute path of the input file
input_file=$(realpath "$input_file")

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file not found."
    exit 1
fi

# Get the filename and extension of the input file
filename=$(basename -- "$input_file")
extension="${filename##*.}"

# Check if the file is either MKV or MP4 format
if [ "$extension" != "mkv" ] && [ "$extension" != "mp4" ]; then
    echo "Error: Input file must be either MKV or MP4 format."
    exit 1
fi

# Get the output folder (same as input folder if not provided)
output_folder=$(dirname "$input_file")

# Create the output folder if it doesn't exist
mkdir -p "$output_folder"

# Calculate the duration of the input video
duration=$(ffprobe -i "$input_file" -show_entries format=duration -v quiet -of csv="p=0")

# Calculate the duration of each segment
segment_duration=$(awk "BEGIN {print $duration / $num_segments}")

# Iterate over the number of segments and extract each segment
for ((i = 0; i < num_segments; i++)); do
    # Calculate the start and end time for the segment
    start_time=$(awk "BEGIN {print $i * $segment_duration}")
    end_time=$(awk "BEGIN {print ($i + 1) * $segment_duration}")

    # Create a filename for the segment
    segment_filename="${filename%.*}_segment$((i+1)).$extension"

    # Run ffmpeg to extract the segment
    ffmpeg -i "$input_file" -ss "$start_time" -to "$end_time" -c copy "$output_folder/$segment_filename"
done

echo "Video successfully divided into $num_segments segments."

