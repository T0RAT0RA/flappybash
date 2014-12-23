#!/bin/bash

declare quit=false
declare -i height=10
declare -i width=30
declare -i bird_pos_y=height/2
declare -i bird_pos_x=3

declare -i wall_pos_y=0
declare -i wall_pos_x=0

declare -ri fps=60
declare -ri gravity_fps=3
declare -i score=0
declare -i last_update=0
declare -i gravity_last_update=0

#-------------------------
# HELPERS
#-------------------------
#COLOR:
#How to use: echo $(color red "Some error in red")
function color() {
    local color=${1}
    shift
    local text="${@}"

    case ${color} in
        red    ) tput setaf 1 ;;
        green  ) tput setaf 2 ;;
        yellow ) tput setaf 3 ;;
        blue   ) tput setaf 4 ;;
        pink   ) tput setaf 5 ;;
        cyan   ) tput setaf 6 ;;
        grey   ) tput setaf 7 ;;
    esac

    echo -en "${text}"
    tput sgr0
}
#-------------------------

function usage {
    echo "bash $0"
    echo "Bash version of Flappy Bird"
    echo "Use W key to fly"
    echo " "
    echo "Examples:"
    echo "  bash $0"
    exit 0
}

function draw() {
    printf "+------------------------------+\n"
    for Y in $(seq 1 $height); do
        printf "|"
        for X in $(seq 1 $width); do
            if [[ $bird_pos_x -eq $X && $bird_pos_y -eq $Y ]]; then
                echo -en "\033[96m*\033[0m";
            elif [[ $wall_pos_y -ne $Y && $wall_pos_x -eq $X ]]; then
                echo -en "\033[92m#\033[0m";
            else
                printf " ";
            fi
        done
        printf "|\n"
    done
    printf "+------------------------------+\n"
    echo "SCORE: "$(color pink $score)
    echo "KEYS : "
    echo "  "$(color green "W")": fly"
    echo "  "$(color green "Q")": quit"
}

function clearScreen () {
    for Y in $(seq 1 $(($height + 6))); do
        tput cuu1
    done
}

function update() {
    #check bird boundaries
    if [[ $bird_pos_y -gt $height || $bird_pos_y -lt 1 ]]; then
        quit=true
        tput el
        echo $(color red "OFF LIMIT")
    fi

    #move the wall
    let wall_pos_x--

    #check wall boundaries
    if [[ $wall_pos_x -lt 1 ]]; then
        addWall
    fi

    if [[ $bird_pos_x -eq $wall_pos_x && $bird_pos_y -ne $wall_pos_y ]]; then
        quit=true
        tput el
        echo $(color red "YOU DIED")
    fi

    #Add a point when bird successfuly pass a wall
    if [[ $bird_pos_x -eq $wall_pos_x && $bird_pos_y -eq $wall_pos_y ]]; then
        let score++
    fi

    #Oh damn gravity
    current_time=$( perl -MTime::HiRes -e 'print int(1000 * Time::HiRes::gettimeofday),"\n"' )
    gravity_elapsed_time=$(($current_time - $gravity_last_update))
    if [[ $gravity_last_update -eq 0 || $gravity_elapsed_time -gt $(( 1000 / $gravity_fps )) ]]; then
        let bird_pos_y++
        gravity_last_update=$( perl -MTime::HiRes -e 'print int(1000 * Time::HiRes::gettimeofday),"\n"' )
    fi
}

function addWall() {
    wall_pos_y=$(($RANDOM%$height))
    wall_pos_x=$width
}
#-------------------------
# MAIN PROGRAM STARTS HERE
#-------------------------
if [[ "/bin/bash" != $BASH ]]; then
    echo $(color red "Use bash to run this program.")
    usage
fi

if [ -t 0 ]; then
    stty -echo -icanon time 0 min 0
fi

clear

#Init wall
addWall

#main loop
while ! $quit; do
    current_time=$( perl -MTime::HiRes -e 'print int(1000 * Time::HiRes::gettimeofday),"\n"' )
    elapsed_time=$(($current_time - $last_update))


    if [[ $last_update -eq 0 || $elapsed_time -gt $(( 1000 / $fps )) ]]; then

        read keypressed
        case $keypressed in
            "q") quit=true ;;
            "a") addWall ;;
            "w") let bird_pos_y-=2 ;;

            #Oh damn gravity
            ##*) let bird_pos_y++ ;;
        esac

        clearScreen
        update
        draw

        last_update=$( perl -MTime::HiRes -e 'print int(1000 * Time::HiRes::gettimeofday),"\n"' )
    fi
done

if [ -t 0 ]; then
    stty sane
fi;

exit 0