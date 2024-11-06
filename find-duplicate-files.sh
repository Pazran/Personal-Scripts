#!/usr/bin/bash

function cursorBack() {
  echo -en "\033[$1D"
}

IFS=$'\n'
a=0
FILE_TYPE="*.*"
TEMP_FILE=$(mktemp '/tmp/dupe-list.XXXXXXXX')
find Downloads -type f -name "$FILE_TYPE" -size -10M -exec md5sum {} + | sort -k 1,1 |  uniq -D -w 33 > $TEMP_FILE &

pid=$!
#spin='-\|/'
#spin='⣾⣽⣻⢿⡿⣟⣯⣷'
#spin='◐◓◑◒'
#spin='┤┘┴└├┌┬┐'
spin="▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"
#spin="▉▊▋▌▍▎▏▎▍▌▋▊▉"
#spin='⠁⠂⠄⡀⢀⠠⠐⠈'
z=0
tput civis
while ps -p $pid >/dev/null
do
    z=$(((z+3)%${#spin}))
    printf "\rFinding duplicate files for file type: $FILE_TYPE... ${spin:$z:3}"
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
