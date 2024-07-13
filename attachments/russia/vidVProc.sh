#!/bin/bash

filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

ffmpeg -i $1 -vf scale=480:800 videos/${filename}.dest.${extension}

echo "<video width='100%' controls>
    <source src='videos/${filename}.dest.${extension}' type='video/mp4'>
</video>" | pbcopy
