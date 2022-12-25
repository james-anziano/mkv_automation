#!/bin/bash

# TODO accept the below as arguments
command=""

starting_season="01"
ending_season="03"
starting_episode="01"
ending_episode="10"

shopt -s extglob
for season in $( seq -w $starting_season $ending_season ); do
    for episode in $( seq -w $starting_episode $ending_episode ); do
        command="${command//S+([0-9])/S$season}"
        command="${command//E+([0-9])/E$episode}"
        eval "$command"
    done
done
