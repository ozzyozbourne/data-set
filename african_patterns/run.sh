#!/bin/bash

command = 'ffmpeg -y -i {} \
        -vf "scale=512:512:force_original_aspect_ratio=decrease:flags=lanczos,pad=512:512:(ow-iw)/2:(oh-ih)/2:black,setsar=1:1" \
        -q:v 2 -update 1 after/{/}'

parallel --bar -j $(nproc) ${command} ::: *.jpeg
