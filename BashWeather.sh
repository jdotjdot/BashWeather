#!/bin/bash

# while getopts ":c:l:u:" opt
# do
#     case $opt in
#         c  )   # default character to display if no weather, leave empty for none
#             local c=${OPTARG}
#         l  )   # supply location instead of using internet
#             local l={$OPTARG}
#         u  )   # how often to update weather in seconds
#             local u={$OPTARG}
#         \? )
#             echo "Invalid option: -$OPTARG" >&2
#             ;;
#         :  )
#             echo "Option -$OPTARG requires an argument." >&2
#             exit 1
#             ;;
#     esac
# done




# switch for default char
# switch for using internet location or your own location

### This needs to be fixes b/c RunLocateMe breaks if there's no internet
# If online, do weather
# function check_internet {
#     if [ -z $BASHWEATHER_FIRSTRUN ] ; then
#       BASHWEATHER_FIRSTRUN="run already"
#        # check if there is internet
#       wget -q --tries=10 --timeout=20 http://google.com
#       if [[ $? -eq 0 ]]; then
#           local INTERNET=true
#       else
#           local INTERNET=false
#       fi
#     fi
# }
############


local NOW=$(date +%s)

# 10800 is 3 hours in Unix time--so we download the weather again after 3 hours
# 3600 is 1 hour
if [ -z $LAST_TIME_CHECKED_WEATHER ] ; then # on startup

  read LAT LON <<<$(~/Coding/BashWeather/RunLocateMe -f "{LAT} {LON}")
  local RESPONSEHOLDER=$(curl -s "http://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON" 2>/dev/null)
  #echo $RESPONSEHOLDER

  LAST_TIME_CHECKED_WEATHER=$NOW
  local UPDATED=""
  local ASSIGN_AGAIN=true

elif [ $LAST_TIME_CHECKED_WEATHER -lt $(($NOW - 10800)) ] ; then # because would be int rather than empty string

 read LAT LON <<<$(~/Coding/BashWeather/RunLocateMe -f "{LAT} {LON}")
 local RESPONSEHOLDER=$(curl -s "http://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON" 2>/dev/null)
 #echo $RESPONSEHOLDER

 local UPDATED=" (updated weather)" # only adds for later updates, not for prompt initialization
 LAST_TIME_CHECKED_WEATHER=$NOW
 local ASSIGN_AGAIN=true

else
    local UPDATED=""
fi

if [ $ASSIGN_AGAIN ] ; then
  local WEATHERCODE=$(echo $RESPONSEHOLDER | grep -o -e '"weather":[^[]*\[[^{]*{[^}]*"id": *[0-9]\{1,3\}' | tail -c 4)
  local SUNRISE=$(echo $RESPONSEHOLDER | grep -o -e '"sunrise":[0-9]\{10\}' | tail -c 11)
  local SUNSET=$(echo $RESPONSEHOLDER | grep -o -e '"sunset":[0-9]\{10\}' | tail -c 11)

    if [ -n $WEATHERCODE ] ; then
          if [ ${WEATHERCODE:0:1} -eq "2" ] ; then
              WEATHERCHAR=☔︎
          elif [ ${WEATHERCODE:0:1} -eq "3" ] ; then
              WEATHERCHAR=☂
          elif [ ${WEATHERCODE:0:1} -eq "5" ] ; then
              WEATHERCHAR=☔︎
          elif [ ${WEATHERCODE:0:1} -eq "6" ] ; then
              WEATHERCHAR=☃
          elif [ ${WEATHERCODE:0:1} -eq "8" ] ; then
              if [ $NOW -lt $SUNRISE ] ; then
                WEATHERCHAR=☽
              elif [ $NOW -gt $SUNRISE -a $NOW -lt $SUNSET ] ; then
                WEATHERCHAR=☀︎;
              elif [ $NOW -gt $SUNSET ] ; then
                WEATHERCHAR=☽
              fi
          else
              WEATHERCHAR=‽ # if no weathercode make interrobang
          fi
    else
        WEATHERCHAR=‽ # if internet dead so no WEATHERCODE
    fi
else
    # get rid of $UPDATED from $WEATHERCHAR
    if [ "${WEATHERCHAR:${#WEATHERCHAR} - 17}" == "(updated weather)" ]; then
        WEATHERCHAR="${WEATHERCHAR:0:1}"
    fi
fi

# echo $UPDATED
WEATHERCHAR=$(echo -n "$WEATHERCHAR" && echo "$UPDATED" | sed 's/ *$//')
# echo $WEATHERCHAR

# if [[ ! -z $UPDATED ]] ; then
#     WEATHERCHAR=$WEATHERCHAR$UPDATED
# fi

#echo "UPDATED: "$UPDATED
#echo "WEATHERCHAR: "$WEATHERCHAR
