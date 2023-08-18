#!/bin/bash

##########################################################
# Script: download-large-file.sh
# Description: This script downloads a large file from a given URL and allows the user to set the filename for the downloaded file.
#              It supports resuming a partially downloaded file if the download is interrupted or stopped.
# Usage: download-large-file.sh <file_url> [file_name] [output_path]
# Arguments:
#   <file_url>   : The URL of the large file to download.
#   [file_name]  : (Optional) The desired filename for the downloaded file. If not provided, a default filename based on the URL will be used.
#   [output_path]: (Optional) The output directory where the file will be downloaded. If not provided, the file will be downloaded to the current directory.
##########################################################

# Function to download a large file from a given URL using wget
download_large_file() {
    local url="$1"
    local filename="$2"
    local output_path="$3"

    # Create the output directory if it doesn't exist
    mkdir -p "$output_path"

    # Check if the file already exists to resume the download
    if [ -f "${output_path}/${filename}" ]; then
        echo "Resuming download of ${output_path}/${filename}..."
        wget -c -O "${output_path}/${filename}" "$url"
    else
        echo "Starting download of ${output_path}/${filename}..."
        wget -O "${output_path}/${filename}" "$url"
    fi
}

# Check if the user requested help
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0 <file_url> [file_name] [output_path]"
    exit 1
fi

# Check if the user provided the URL as the first argument
if [ -z "$1" ]; then
    echo "Error: <file_url> not provided. Usage: $0 <file_url> [file_name] [output_path]"
    exit 1
fi

# Get the URL from the first command-line argument
file_url="$1"

# Check if the user provided the desired filename as the second argument
if [ -z "$2" ]; then
    # If the filename is not provided, use a default filename based on the URL
    filename="$(basename "$file_url")"
else
    # If the filename is provided, use it as is
    filename="$2"
fi

# Check if the user provided the output path as the third argument
if [ -z "$3" ]; then
    # If the output path is not provided, use the current directory
    output_path="."
else
    # If the output path is provided, use it as is
    output_path="$3"
fi

# Call the function to download the file
download_large_file "$file_url" "$filename" "$output_path"

echo "Download completed. File saved as: ${output_path}/${filename}"

