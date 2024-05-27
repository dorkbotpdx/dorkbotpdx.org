#!/bin/bash

THEDATE=""
THENAME=""
EVENTDATE=""
TMPF=block.txt

echo -n > $TMPF

ICAL_URL=https://calendar.google.com/calendar/ical/2f03821cdf4512383f4eeb3b3ef44af6f6d09f3c3ded6a097dffb6c2e7f84b9a%40group.calendar.google.com/public/basic.ics

# TODO: Fetch url

while read -r line ; do
  if [[ "$line" =~ ^DTSTART* ]] ; then
    T=$(echo $line | sed -e "s/^DTSTART://")
    #echo "hey $T"
    #echo "${T:0:4}-${T:4:2}-${T:6:2} ${T:9:2}:${T:11:2}:${T:13:2}${T:15:1}"
    F=$(echo "${T:0:4}-${T:4:2}-${T:6:2} ${T:9:2}:${T:11:2}:${T:13:2}${T:15:1}")
    #date -d "$F"
    #date '+%Y%m%d' -d "$F"
    NOW=$(date '+%Y%m%d')
    THEDATE=$(date '+%B %eth, %Y' -d "$F")
    EVENTDATE=$(date '+%Y%m%d' -d "$F")
    #echo $THEDATE
  fi
  if [[ "$line" =~ ^SUMMARY* ]] ; then
    THENAME=$(echo $line | sed -e "s/^SUMMARY://")
    NOW=$(date '+%Y%m%d')
    if [[ "$EVENTDATE" > "$NOW" ]] || [[ "$EVENTDATE" == "$NOW" ]] ; then
      #echo $EVENTDATE is greater than $NOW
      echo "$EVENTDATE $THEDATE - $THENAME" >> $TMPF
    fi
  fi
done

BLOCK=$(cat $TMPF | sort | sed -e "s/^........ //")