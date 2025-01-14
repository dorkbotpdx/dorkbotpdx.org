#!/bin/bash

THEDATE=""
THENAME=""
EVENTDATE=""
ICALTMP=ical.tmp
TMPF=block.txt

echo -n > $TMPF

ICAL_URL=https://calendar.google.com/calendar/ical/2f03821cdf4512383f4eeb3b3ef44af6f6d09f3c3ded6a097dffb6c2e7f84b9a%40group.calendar.google.com/public/basic.ics

echo Fetching ical url
curl -qs $ICAL_URL > $ICALTMP

while read -r line ; do
  if [[ "$line" =~ ^DTSTART* ]] ; then
    T=$(echo $line | sed -e "s/^DTSTART://")
    F=$(echo "${T:0:4}-${T:4:2}-${T:6:2} ${T:9:2}:${T:11:2}:${T:13:2}${T:15:1}")
    echo here1
    NOW=$(TZ=America/Los_Angeles date '+%Y%m%d')
    echo here2 $F
    THEDATE=$(TZ=America/Los_Angeles date '+%B %eth, %Y' -d "$F")
    echo here3 $F
    EVENTDATE=$(TZ=America/Los_Angeles date '+%Y%m%d' -d "$F")
    echo here4
  fi
  if [[ "$line" =~ ^SUMMARY* ]] ; then
    THENAME=$(echo $line | sed -e "s/^SUMMARY://")
    NOW=$(TZ=America/Los_Angeles date '+%Y%m%d')
    if [[ "$EVENTDATE" > "$NOW" ]] || [[ "$EVENTDATE" == "$NOW" ]] ; then
      echo "$EVENTDATE $THEDATE - $THENAME" >> $TMPF
    fi
  fi
done < $ICALTMP

cat $TMPF | sort | sed -e "s/^........ //" > $TMPF.2
# If the event name is just "Dorkbot: Month Edition" then remove it
# Other event names should be fine
cat $TMPF.2 | sed -e 's/ - Dorkbot: \w\+ Edition//' > $TMPF.3
cat $TMPF.3 | sed -e "s/^/      <strong>/"  | sed -e 's/\r/<\/strong><br\/>/' > $TMPF

echo "Here are the upcoming meeting dates:"
cat $TMPF

START=$(grep -n '<!-- XX MEETINGS START -->' index.html | sed -e 's/:.*//')
END=$(grep -n '<!-- XX MEETINGS END -->' index.html | sed -e 's/:.*//')

head -$START index.html > top.tmp
tail +$END index.html > bot.tmp

cat top.tmp > index.html
cat $TMPF >> index.html
cat bot.tmp >> index.html

# cleanup
rm $ICALTMP
rm top.tmp
rm bot.tmp
rm $TMPF $TMPF.2 $TMPF.3