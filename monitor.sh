#!/bin/bash

# Logz.io Key
# LOGZ_TOKEN="your_token_here"
if [[ -z "${LOGZ_TOKEN}" ]]; then
  echo "Environment variable LOGZ_TOKEN is undefined"
  exit
fi
# Интервал отправки данных
TIME_INTERVAL=10
DIRECTORY=$(cd `dirname $0` && pwd)

trap "exit" INT TERM ERR
trap "kill 0" EXIT

echo "Start"

function start_tail() {
  echo "Start tail $1 to $2.log"
  tail -Fq -n0 $1 >> $DIRECTORY/send/$2.log
}

function start_monitor() {
  echo "Start listen $1 for $2.log"
  file_mask="${1##*/}"
  file_mask="${file_mask/\*/.*}"
  inotifywait -m -r $(dirname "$1") -e create 2> /dev/null |
  while read path action file; do
    if [[ "$path$file" =~ $file_mask ]]; then
        echo "New file $path$file stream to $2.log"
        tail -Fq -n1000 $path$file >> $DIRECTORY/send/$2.log
    fi
  done
}

find $DIRECTORY/conf/ -type f -size +0c |
  while read file; do
    echo "Read type \"${file##*/}\""
    while IFS= read -r line; do
      if [[ "$line" == "" ]]; then
        continue
      fi
      start_tail "$line" "${file##*/}" &
      if [[ "$line" =~ \* ]]; then
        start_monitor "$line" "${file##*/}" &
      fi
    done < $file
  done

while :
do
  find $DIRECTORY/send/ -type f -size +0c |
    while read file; do
      channel=$(basename "$file" .log)
      echo "Process $file as type $channel"
      cp $file $file.tmp
      > $file
      if [[ "$file" =~ json\.log$ ]]; then
        cat $file.tmp | curl -X POST "https://listener.logz.io:8071?token=$LOGZ_TOKEN&type=$channel" -v --data-binary @-
      else
        curl -T $file.tmp "https://listener.logz.io:8022/file_upload/$LOGZ_TOKEN/$channel"
      fi
      rm $file.tmp
    done
  sleep $TIME_INTERVAL
done
