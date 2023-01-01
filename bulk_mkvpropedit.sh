usage() {
cat << EOF

    Usage: $0 <filepath> [options]

    -h,  --help                 Display help

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

options=$(getopt -l "help,audio:,subtitle:,forced:" -o "h" -a "ad,sd,sf" -- "$@")

default_audio_track=false
default_subtitle_track=false
forced_subtitle_track=false
testing=false

filepath="$1"

while true; do
    case "$2" in
        -h|--help)
            usage
            exit 0
            ;;
        -ad|--default-audio)
            shift
            default_audio_track="$2"
            ;;
        -sd|--default_subtitle)
            shift
            default_subtitle_track="$2"
            ;;
        -sf|--forced_subtitle)
            shift
            forced_subtitle_track="$2"
            ;;
        -t|--testing)
            shift
            testing=true
            ;;
        --|*)
            shift
            break
            ;;
    esac
    shift
done

if [[ ! -d "$filepath" ]]; then
    echo "'$filepath' is not a directory or does not exist."
    exit 1
fi
if [[ ! $default_audio_track == false && ! $default_audio_track =~ ^[0-9]+$ ]]; then
    echo "Default audio track '$default_audio_track' must be an integer."
    exit 1
fi
if [[ ! $default_subtitle_track == false && ! $default_subtitle_track =~ ^[0-9]+$ ]]; then
    echo "Default subtitle track '$default_subtitle_track' must be an integer."
    exit 1
fi
if [[ ! $default_subtitle_track == false && ! $forced_subtitle_track =~ ^[0-9]+$ ]]; then
    echo "Forced subtitle track '$forced_subtitle_track' must be an integer."
    exit 1
fi

# TODO set these flags =0 for all other tracks
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
else
    echo "Running $command"
    eval "$command"
fi
