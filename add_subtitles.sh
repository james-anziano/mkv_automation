#!/bin/bash

usage() {
cat << EOF

    Usage: $0 [OPTION...] EPISODES_DIR SUBTITLES_DIR

Add subtitle files to a batch of video files.

    EPISODES_DIR                Directory of episode video files.

    SUBTITLES_DIR               Directory of subtitle folders of files. This script expects the
                                following structure:
                                SUBTITLES_DIR/episode_1_filename/subtitle_file.srt
                                SUBTITLES_DIR/episode_2_filename/subtitle_file.srt
                                ...
                                where the 'episode_1_filename' will be the filename of each
                                corresponding episode video file, minus any file extensions.

    -h,  --help                 Display help.

    -er, --episode-range        Range of episodes to add subtitles to. Range strings
                                should follow the format of "##-##", with as many significant
                                digits as the filenames have. Defaults to "01-01".

    -t,  --testing              Outputs the command to be run with the specified options.
                                Equivalent of a dry run.

EOF
}

episode_range='01-01'
testing=false

positional_args=()

while [ "$1" != "" ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -er|--episode-range)
            episode_range="$2"
            shift
            ;;
        -t|--testing)
            testing=true
            ;;
        --|*)
            if [[ "$1" =~ ^- ]]; then
                echo "Unrecognized argument: $1"
                exit 1
            else
                positional_args+=("$1")
            fi
            ;;
    esac
    shift
done

if (( ${#positional_args[@]} < 2 )); then
    echo "ERROR: Please supply both EPISODES_DIR and SUBTITLES_DIR."
    exit 1
fi
if (( ${#positional_args[@]} > 2 )); then
    echo "ERROR: too many positional arguments found. Please supply only EPISODES_DIR and SUBTITLES_DIR."
    exit 1
fi

episodes_dir="${positional_args[0]}"
subtitles_dir="${positional_args[1]}"

if [[ ! -d $episodes_dir ]]; then
    echo "ERROR: $episodes_dir is not a directory or does not exist."
    exit 1
fi
if [[ ! -d $subtitles_dir ]]; then
    echo "ERROR: $subtitles_dir is not a directory or does not exist."
    exit 1
fi

if [[ ! $episode_range =~ ^[0-9]+-[0-9]+$ ]]; then
    echo "ERROR: Invalid episode range. Range strings should follow the format of \"##-##\", with as many significant digits as the filenames have."
    exit 1
fi

IFS='-' read -ra episode_start_end <<< "$episode_range"

starting_episode="${episode_start_end[0]}"
ending_episode="${episode_start_end[1]}"

shopt -s extglob
sample_filename=$(ls $episodes_dir/*.@(mp4|avi) | head -1)

for episode in "$episodes_dir/*.@(mp4|avi)"; do
    episode_filename=$(basename $episode)
    # Remove the file extension
    episode_name="${episode_filename%.*}"
    command="/usr/bin/mkvmerge --ui-language en_US --priority lower --output $episodes_dir/$episode_name.mkv --language 0:und --language 1:en '(' $episode ')'"
    for subtitle in "$subtitles_dir/$episode_name/*.(srt|ass)"; do
        command="$command  --language 0:en --default-track-flag 0:no '(' $subtitle ')'"
    done
    command="$command  --track-order 0:0,0:1,1:0,2:0"
    if [[ $testing == true ]]; then
        echo "The command which would have been run for episode $episode:"
        echo "$command"
        echo ""
    else
        echo "Running $command"
        eval "$command"
        echo ""
    fi
done
