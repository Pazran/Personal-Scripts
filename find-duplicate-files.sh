#!/usr/bin/bash

function cursorBack() {
  echo -en "\033[$1D"
}

IFS=$'\n'
a=0
FILE_DIR='/home/clara/Desktop'
TEMP_FILE=$(mktemp '/tmp/dupe-list.XXXXXXXX')

#If no argument passed, use the default value for file type and size
if [[ $# -ge 2 ]];
then
    while getopts "n:s:" option;
    do
        case "${option}" in
          n)FILE_NAME=${OPTARG};;
          s)FILE_SIZE=${OPTARG};;
        esac
    done
    #Get the remaining argument
    shift $(($OPTIND - 1))
    #echo $*
    FILE_DIR="$*"

    if [ "$FILE_DIR" = './' ] || [ "$FILE_DIR" = '.' ]
    then
        FILE_DIR="${PWD}"
    else
        FILE_DIR="$*"
    fi

    find "$FILE_DIR" -type f -name "$FILE_NAME" -size $FILE_SIZE -exec md5sum {} + | sort -k 1,1 |  uniq -D -w 33 > $TEMP_FILE &
else
    find /home/clara/Desktop -type f -name "*.*" -size +10M -exec md5sum {} + | sort -k 1,1 |  uniq -D -w 33 > $TEMP_FILE &
fi

pid=$!
#spin='-\|/'
spin="▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"
z=0
tput civis
while ps -p $pid >/dev/null
do
    z=$(((z+3)%${#spin}))
    printf "\rFinding duplicate files in $FILE_DIR ${spin:$z:3}"
    cursorBack 1
    sleep .1
done
tput cnorm
for i in $(cat $TEMP_FILE)
do
    printf "\n$i"
    ((a++))
done
printf "%.0s\n" {1..2}
printf '%s\n' "$a duplicate files found"
rm $TEMP_FILE
