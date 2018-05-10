#!/bin/bash

if ! command -v cwebp &> /dev/null
then
    echo "cwebp could not be found. Please install libwebp-tools or similar package."
    exit 1
fi

for file in *.png; do
    if [ -f "$file" ]; then
        filename="${file%.*}"
        output_file="${filename}.webp"
        # gm convert -quality 100 -define webp:lossless=true -define webp:exact=true -define webp:method=6 "$file" "$output_file"
        cwebp -q 100 -lossless -exact -m 6 "$file" -o "$output_file"
        echo "Converted $file to $output_file"
    fi
done

echo "Conversion complete."
