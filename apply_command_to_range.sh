#!/bin/bash

usage() {
cat << EOF

    Usage: $0 <command> [options]

Apply a command to a sequence of seasons and episodes. Be sure to wrap <command> in quotes
so that it can be read as a single argument.

    -h,  --help                 Display help.

    -sr, --season-range         Range of seasons to apply command to. Range strings
                                should follow the format of "##-##", with as many significant
                                digits as the filenames have.

    -er, --episode-range        Range of episodes to apply command to. Range strings
                                should follow the format of "##-##", with as many significant
                                digits as the filenames have.

    -t,  --testing              Outputs the command to be run with the specified options.
                                Equivalent of a dry run.

EOF
}

season_range='01-01'
episode_range='01-01'
testing=false

positional_args=()

while [ "$1" != "" ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -sr|--season-range)
            season_range="$2"
            shift
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

if (( ${#positional_args[@]} < 1 )); then
    echo "Please supply <command>"
    exit 1
fi
if (( ${#positional_args[@]} > 1 )); then
    echo "Please supply only one <command>"
    exit 1
fi
command="${positional_args[0]}"

if [[ ! $season_range =~ ^[0-9]+-[0-9]+$ ]]; then
    echo "Invalid season range. Range strings should follow the format of \"##-##\", with as many significant digits as the filenames have."
    exit 1
fi
if [[ ! $episode_range =~ ^[0-9]+-[0-9]+$ ]]; then
    echo "Invalid episode range. Range strings should follow the format of \"##-##\", with as many significant digits as the filenames have."
    exit 1
fi

IFS='-' read -ra season_start_end <<< "$season_range"
IFS='-' read -ra episode_start_end <<< "$episode_range"

starting_season="${season_start_end[0]}"
ending_season="${season_start_end[1]}"
starting_episode="${episode_start_end[0]}"
ending_episode="${episode_start_end[1]}"

shopt -s extglob
for season in $( seq -w $starting_season $ending_season ); do
    for episode in $( seq -w $starting_episode $ending_episode ); do
        command="${command//S+([0-9])/S$season}"
        command="${command//E+([0-9])/E$episode}"
        if [[ $testing == true ]]; then
            echo "The command which would have been run:"
            echo "$command"
        else
            echo "Running $command"
            eval "$command"
        fi
    done
done
