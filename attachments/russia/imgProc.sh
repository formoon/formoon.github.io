#!/bin/bash
filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"
#echo ${1} ${filename}.dest.${extension}
#convert ${1} imgs/andrewLogo.png -size 1280 -gravity southwest -geometry +10+10 -composite ${filename}.dest.${extension}
magick ${1} \
    -resize "1280" \
    \( imgs/andrewLogo.png -resize "240" \) \
    -gravity southwest -geometry +10+10 \
    -composite \
    imgs/${filename}.dest.${extension}
echo "![](imgs/${filename}.dest.${extension})" | pbcopy
