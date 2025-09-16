#!/bin/bash

# go into the results folder
cd results || exit 1

# make the subfolder for pngs
mkdir -p pngfigures

# loop over all PDFs and convert to PNG
for pdf in *.pdf; do
    if [ -f "$pdf" ]; then
        # strip .pdf and replace with .png
        base=$(basename "$pdf" .pdf)
        convert -density 300 "$pdf" "pngfigures/${base}.png"
        echo "Converted $pdf → pngfigures/${base}.png"
    fi
done
