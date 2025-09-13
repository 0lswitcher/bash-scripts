#!/bin/bash

# define directories
DOWNLOADS_DIR="/home/y2k/Downloads"
DOWNLOADS_DIR_LOWER="/home/y2k/downloads"
TEMP_DIR="/home/y2k/stuff/temp"

# function to handle a downloads directory
handle_downloads_dir() {
    local dir="$1"
    echo "Downloads folder detected: $dir"
    
    # check if directory is empty
    if [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
        echo "Downloads folder is empty, deleting..."
        rmdir "$dir"
        echo "Downloads folder deleted"
    else
        echo "Downloads folder contains files:"
        ls -lA "$dir"
        echo
        
        # count files (excluding . and ..)
        file_count=$(ls -1A "$dir" | wc -l)
        
        if [ "$file_count" -eq 1 ]; then
            file_name=$(ls -1A "$dir")
            echo "Found 1 file: $file_name"
        else
            echo "Found $file_count files"
        fi
        
        echo -n "Would you like to move $([ "$file_count" -eq 1 ] && echo "this file" || echo "these files") to $TEMP_DIR and delete the Downloads folder? (y/N): "
        read -r response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            # create temp directory if it doesn't exist
            mkdir -p "$TEMP_DIR"
            
            # move all files
            if mv "$dir"/* "$TEMP_DIR"/ 2>/dev/null; then
                echo "Files moved to $TEMP_DIR"
                
                # delete the empty downloads directory
                rmdir "$dir"
                echo "Downloads folder deleted"
            else
                echo "Error: Failed to move files. Downloads folder not deleted."
            fi
        else
            echo "Operation cancelled. Downloads folder preserved."
        fi
    fi
}

# check for Downloads directory (capitalized)
if [ -d "$DOWNLOADS_DIR" ]; then
    handle_downloads_dir "$DOWNLOADS_DIR"
# check for downloads directory (lowercase)
elif [ -d "$DOWNLOADS_DIR_LOWER" ]; then
    handle_downloads_dir "$DOWNLOADS_DIR_LOWER"
else
    echo "No downloads folder detected"
fi
