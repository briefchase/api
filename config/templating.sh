#!/bin/bash

# Check for jq
if ! command -v jq &> /dev/null
then
    echo "This script requires 'jq' for JSON parsing. Please install it."
    exit 1
fi

# Validate arguments
if [[ -z "$1" || -z "$2" || ! -f "$1" ]]; then
    echo "Usage: $0 <config.json> <directory_or_file>"
    exit 1
fi

CONFIG_FILE="$1"
TARGET_PATH="$2"

# Process each file
process_file() {
    local file="$1"
    
    while read -r key value; do
        # Use sed to replace
        sed -i "s/{${key}}/${value}/g" "$file"
    done < <(jq -r 'to_entries[] | "\(.key) \(.value)"' "$CONFIG_FILE")
}

export -f process_file

# Check if the target path is a file or directory
if [[ -d "$TARGET_PATH" ]]; then
    # It's a directory: recursively find all files and run process_file on each
    find "$TARGET_PATH" -type f -exec bash -c 'process_file "$0"' {} \;
elif [[ -f "$TARGET_PATH" ]]; then
    # It's a file: just process it
    process_file "$TARGET_PATH"
else
    echo "Error: $TARGET_PATH is neither a valid directory nor a file."
    exit 1
fi

echo "Processing completed."
