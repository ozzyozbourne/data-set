#!/bin/bash

usage() {
    echo "Usage: $0 <pattern_dir>"
    echo ""
    echo "Valid pattern directories:"
    echo "  indian_patterns"
    echo "  african_patterns"
    echo ""
    echo "Example:"
    echo "  $0 indian_patterns"
    echo ""
    echo "This script checks that all images in <pattern_dir>/after/"
    echo "are exactly 512x512 using ffprobe + GNU parallel."
    exit 1
}

check_file() {
    local file="$1"

    local dim
    dim=$(ffprobe -v error -select_streams v:0 \
        -show_entries stream=width,height \
        -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null)

    local width height
    width=$(echo "$dim" | sed -n '1p')
    height=$(echo "$dim" | sed -n '2p')

    if [[ "$width" == "512" && "$height" == "512" ]]; then
        echo "✅ $file : ${width}x${height}"
    else
        echo "❌ $file : ${width}x${height}"
    fi
}


if [[ $# -ne 1 ]]; then
    usage
fi

PATTERN_DIR="$1"

case "$PATTERN_DIR" in
    indian_patterns|african_patterns)
        ;;
    *)
        echo "❌ Error: Invalid input '$PATTERN_DIR'"
        echo "Allowed values: 'indian_patterns' or 'african_patterns'"
        exit 1
        ;;
esac

if [[ ! -d "$PATTERN_DIR/after" ]]; then
    echo "❌ Error: '$PATTERN_DIR/after' directory not found."
    exit 1
fi

echo "🔍 Checking all images in: $PATTERN_DIR/after"
echo ""

export -f check_file

parallel --bar -j "$(nproc)" check_file ::: "$PATTERN_DIR"/after/*.jpeg 2>/dev/null

echo ""
echo "✅ Check complete!"
