#!/bin/bash

shopt -s extglob

# TODO Accept the below as arguments
num_episodes=0
input_dir=""
subtitles_dir=""
subtitle_filepaths=()

sample_filename=$(ls $input_dir/*.@(mp4|avi) | head -1)

for episode in $( seq -w 01 $num_episodes ); do
    current_episode_filepath="${sample_filename//E+([0-9])/E$episode}"
    current_episode_filename=$(basename $current_episode_filepath)
    # Remove the file extension
    current_episode_name="${current_episode_filename%.*}"
    command="/usr/bin/mkvmerge --ui-language en_US --priority lower --output $input_dir/$current_episode_name.mkv --language 0:und --language 1:en '(' $current_episode_filepath ')'"
    for subtitle_filepath in subtitle_filepaths; do
        subtitle_filepath="${subtitle_filepath//E+([0-9])/E$episode}"
        command="$command  --language 0:en --default-track-flag 0:no '(' $subtitle_filepath ')'"
    done
    command="$command  --track-order 0:0,0:1,1:0,2:0"
    echo "$command"
done
