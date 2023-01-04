#!/bin/bash

# TODO Supply a list of default tracks and forced tracks (so it can just be --defaults 'a2,s1' --forced 's1'), etc.
usage() {
cat << EOF

    Usage: $0 <filepath> [options]

For each <filepath> supplied, set the specified flags for the specified tracks.

    -h,  --help                 Display help.

    -ad, --default-audio        Audio track to set as default. All other audio tracks
                                will have their default flag switched off. Must be an
                                integer.

    -sd, --default-subtitle     Subtitle track to set as default. All other subtitle
                                tracks will have their default flag switched off. Must
                                be an integer.

    -sf, --forced-subtitle      Subtitle track to set as forced. All other subtitle
                                tracks will have their forced flag switched off. Must
                                be an integer.

    -t,  --testing              Outputs the command to be run with the specified options.
                                Equivalent of a dry run.

EOF
}

default_audio_track=false
default_subtitle_track=false
forced_subtitle_track=false
testing=false

positional_args=()

while [ "$1" != "" ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -ad|--default-audio)
            default_audio_track="$2"
            shift
            ;;
        -sd|--default-subtitle)
            default_subtitle_track="$2"
            shift
            ;;
        -sf|--forced-subtitle)
            forced_subtitle_track="$2"
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

if (( ${#positional_args[@]} < 1 )); then
    echo "Please supply at least one filepath."
    exit 1
fi

if [[ $default_audio_track != false && ! $default_audio_track =~ ^[0-9]+$ ]]; then
    echo "Default audio track '$default_audio_track' must be an integer."
    exit 1
fi
if [[ $default_subtitle_track != false && ! $default_subtitle_track =~ ^[0-9]+$ ]]; then
    echo "Default subtitle track '$default_subtitle_track' must be an integer."
    exit 1
fi
if [[ $default_subtitle_track != false && ! $forced_subtitle_track =~ ^[0-9]+$ ]]; then
    echo "Forced subtitle track '$forced_subtitle_track' must be an integer."
    exit 1
fi

for filepath in "${positional_args[@]}"; do

    if [[ ! -d "$filepath" ]]; then
        echo "'$filepath' is not a directory or does not exist."
        exit 1
    fi

    # TODO set these flags =0 for all other tracks
    # Need to find a way to determine number of other tracks. Maybe mkvinfo on the first file found by a similar `find` command?
    command="find $filepath -name '*.mkv' -exec mkvpropedit {} "
    if [[ ! $default_audio_track == false ]]; then
        command="$command --edit track:a$default_audio_track --set flag-default=1"
    fi
    if [[ ! $default_subtitle_track == false ]]; then
        command="$command --edit track:s$default_subtitle_track --set flag-default=1"
    fi
    if [[ ! $default_audio_track == false ]]; then
        command="$command --edit track:s$forced_subtitle_track --set flag-forced=1"
    fi

    command="$command \;"
    if [[ $testing == true ]]; then
        echo "The command which would have been run:"
        echo "$command"
        echo ""
    else
        echo "Running $command"
        eval "$command"
        echo ""
    fi
done
