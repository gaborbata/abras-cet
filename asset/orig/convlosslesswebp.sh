#!/bin/bash

if ! command -v gm &> /dev/null
then
    echo "GraphicsMagick could not be found. Please install graphicsmagick package."
    exit 1
fi

for file in *.png; do
    if [ -f "$file" ]; then
        filename="${file%.*}"
        output_file="${filename}.webp"
        # cwebp -q 100 -lossless -exact -m 6 "$file" -o "$output_file"
        gm convert -quality 100 -define webp:lossless=true -define webp:exact=true -define webp:method=6 "$file" "$output_file"
        echo "Converted $file to $output_file"
    fi
done

echo "Conversion complete."
