#!/bin/bash

# Get the current working directory
WORKING_DIR="$(pwd)"
LENGTH=48

clear
echo " .-------------------------."
echo " |Building Moon Patrol ROMs|"
echo " '-------------------------'"

# Create necessary directories
mkdir -p "$WORKING_DIR/arcade/mpatrol"

echo "Copying Moon Patrol ROMs"

# Define the file paths within the folder
FILES=(
    "$WORKING_DIR/mpa-1.3m"
    "$WORKING_DIR/mpa-2.3l"
    "$WORKING_DIR/mpa-3.3k"
    "$WORKING_DIR/mpa-4.3j"
)

# Specify the output file within the folder
OUTPUT_FILE="$WORKING_DIR/arcade/mpatrol/rom1.bin"

# Concatenate the files as binary data
cat "${FILES[@]}" > "$OUTPUT_FILE"

# Copy additional ROM files
cp "$WORKING_DIR/mpe-5.3e" "$WORKING_DIR/arcade/mpatrol/mpe-5.3e"
cp "$WORKING_DIR/mpe-4.3f" "$WORKING_DIR/arcade/mpatrol/mpe-4.3f"
cp "$WORKING_DIR/mpb-2.3m" "$WORKING_DIR/arcade/mpatrol/mpb-2.3m"
cp "$WORKING_DIR/mpb-1.3n" "$WORKING_DIR/arcade/mpatrol/mpb-1.3n"
cp "$WORKING_DIR/mpe-3.3h" "$WORKING_DIR/arcade/mpatrol/mpe-3.3h"
cp "$WORKING_DIR/mpe-2.3k" "$WORKING_DIR/arcade/mpatrol/mpe-2.3k"
cp "$WORKING_DIR/mpe-1.3l" "$WORKING_DIR/arcade/mpatrol/mpe-1.3l"
cp "$WORKING_DIR/mp-s1.1a" "$WORKING_DIR/arcade/mpatrol/mp-s1.1a"

echo "Generating blank config file"

# Create a blank file filled with 0xFF bytes
OUTPUT_FILE="$WORKING_DIR/arcade/mpatrol/mpcfg"
dd if=/dev/zero bs=1 count=$LENGTH | tr '\0' '\377' > "$OUTPUT_FILE"

echo "All done!"
