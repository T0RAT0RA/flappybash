#!/bin/bash

declare quit=false
declare -i height=10
declare -i width=30
declare -i bird_pos_y=height/2
declare -i bird_pos_x=3

declare -i wall_pos_y=0
declare -i wall_pos_x=0

declare -i score=0

function draw() {
    printf "+------------------------------+\n"
    for Y in $(seq 1 $height); do
        printf "|"
        for X in $(seq 1 $width); do
            if [[ $bird_pos_x -eq $X && $bird_pos_y -eq $Y ]]; then
                printf "*";
            elif [[ $wall_pos_y -ne $Y && $wall_pos_x -eq $X ]]; then
                printf "#";
            else
                printf " ";
            fi
        done
        printf "|\n"
    done
    printf "+------------------------------+\n"
    printf "SCORE: $score\n"
}

function update() {
    #check bird boundaries
    if [[ $bird_pos_y -gt $height || $bird_pos_y -lt 1 ]]; then
        quit=true
        printf "OFF LIMIT\n"
    fi

    #move the wall
    let wall_pos_x--

    #check wall boundaries
    if [[ $wall_pos_x -lt 1 ]]; then
        addWall
    fi

    if [[ $bird_pos_x -eq $wall_pos_x && $bird_pos_y -ne $wall_pos_y ]]; then
        quit=true
        printf "YOU DIED\n"
    fi

    #Add a point when bird successfuly pass a wall
    if [[ $bird_pos_x -eq $wall_pos_x && $bird_pos_y -eq $wall_pos_y ]]; then
        let score++
    fi

    #Oh damn gravity
    #let bird_pos_y++
}

function addWall() {
    wall_pos_y=$(($RANDOM%$height))
    wall_pos_x=$width
}

if [ -t 0 ]; then
    stty -echo -icanon time 0 min 0
fi;

#Init wall
addWall

#main loop
while ! $quit; do
    sleep 0.1

    read keypressed
    case $keypressed in
        "q") quit=true ;;
        "a") addWall ;;
        "s") let bird_pos_y++ ;;
        "w") let bird_pos_y-- ;;
    esac

    clear
    update
    draw
done

if [ -t 0 ]; then
    stty sane
fi;

exit 0