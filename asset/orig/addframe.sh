#!/bin/bash

if ! command -v gm &> /dev/null
then
    echo "GraphicsMagick could not be found. Please install graphicsmagick package."
    exit 1
fi

input_file="${1:-input.png}"
output_file="${2:-output.webp}"

lossless_webp="-quality 100 -define webp:lossless=true -define webp:exact=true -define webp:method=6"
resize="-resize 656x"
add_border="-bordercolor #606c76 -border 2x2 -bordercolor #ffffff -border 20x20"

echo "Convert $input_file to $output_file..."
if [ -f "$input_file" ]; then
    gm convert $lossless_webp $resize $add_border "$input_file" "$output_file"
    gm composite $lossless_webp -gravity South "template/footer.webp" "$output_file" "$output_file"
fi
gm identify "$output_file"
