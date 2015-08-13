#!/bin/bash

function url_escape {
  echo $(echo "$@" | sed -e 's/ /%20/g' -e 's/!/%21/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e "s/'/%27/g" -e 's/(/%28/g' -e 's/)/%29/g')
}


function get_symbol {
  # this function takes in the word for the weather character
  #  and returns the right UTF8 encoding in oct for it

  local OUT
  case "$@" in

    sun )        #utf8 hex: \xe2\x98\x80 | unicode: U+2600
                 OUT='\342\230\200';;
    cloud )      #utf8 hex: \xe2\x98\x81 | unicode: U+2601
                 OUT='\342\230\201';;
    umbrella )   #utf8 hex: \xe2\x98\x82 | unicode: U+2602
                 OUT='\342\230\202';;
    snowman )    #utf8 hex: \xe2\x98\x83 | unicode: U+2603
                 OUT='\342\230\203';;
    moon )       #utf8 hex: \xe2\x98\xbd | unicode: U+263D
                 OUT='\342\230\275';;
    umbrellarain) #utf8 hex: \xe2\x98\x94 | unicode: U+2614
                 OUT='\342\230\224';;

    * )   echo "Invalid option provided to get_symbol" >&2
          return 1
          ;;
  esac

  echo "$OUT"
}


# If online, do weather
function check_internet {
    if [ -z "$BASHWEATHER_FIRSTRUN" ] ; then
      BASHWEATHER_FIRSTRUN="run already"
       # check if there is internet
      wget -q --tries=1 --timeout=$t http://google.com -O - 2>/dev/null
      if [[ $? -eq 0 ]]; then
          # local INTERNET=true
          return 0
      else
          # local INTERNET=false
          return 1
      fi
    fi
}

function getResponse {
   local URL="http://api.openweathermap.org/data/2.5/weather?"

   if [ -n "$l" ] ; then
   # if user supplies location or specifies LocateMe
      if [ "$(echo "$l" | tr '[:upper:]' '[:lower:]')" != "locateme" ] ; then
        local ESCAPED_CITY=$(url_escape "$l")
        local RESPONSEHOLDER=$(curl --connect-timeout $t -s "http://api.openweathermap.org/data/2.5/weather?q=$ESCAPED_CITY" 2>/dev/null)
      else
        # Using LocateMe
        check_internet
        if [[ $? -eq 0 ]] ; then
          read LAT LON <<<$($(sourceDirectory)/RunLocateMe -f "{LAT} {LON}")
          local RESPONSEHOLDER=$(curl --connect-timeout $t -s "http://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON" 2>/dev/null)
        fi
      fi
   else
    # default is by IP address
    local TEMPHOLDER=$(curl --connect-timeout $t -s "http://ip-api.com/json/" 2>/dev/null)
    LAT=$(echo $TEMPHOLDER | grep -o -e '"lat":[0-9\.\-]\+' | grep -o -e '[0-9\.\-]\+$')
    LON=$(echo $TEMPHOLDER | grep -o -e '"lon":[0-9\.\-]\+' | grep -o -e '[0-9\.\-]\+$')
    local RESPONSEHOLDER=$(curl --connect-timeout $t -s "http://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON" 2>/dev/null)
   fi


   echo "$RESPONSEHOLDER"
}

function sourceDirectory {
  # Also resolves symlinks
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  echo "$DIR"
}

function runWeather {

  local OPTIND
  while getopts ":c:l:u:s:t:h" opt ; do
      case "$opt" in
          c  )   # default character to display if no weather, leave empty for none
              c="$OPTARG"
              ;;
          l  )   # supply city name instead of using internet or "LocateMe" for RunLocateMe
              l="$OPTARG"
              ;;
          u  )   # how often to update weather in seconds
              u="$OPTARG"
              ;;
          s  )   # weather update alert string to supply, if any
              s="$OPTARG"
              ;;
	        t  )   # http timeout
      	      t="$OPTARG"
      	      ;;
          h  )
              # echo the help file
	      local HELP=$(cat <<"EOF"
USAGE:
    Add `. [/path/to/]BashWeather.sh [options]` to your `.bashrc`,
    then include `$WEATHERCHAR` in your bash `$PROMPT` variable somewhere below that.
    If you plan to use the provided `RunLocateMe` binary that makes use of Mac OS X\'s geolocation feature, make sure that it is located in the same directory as `BashWeather.sh`.

OPTIONS:
+ `-c <character>` - default character to be displayed in your prompt should the weather not be available for any reason.  Default character is the dollar sign ($).  Please note that this will NOT become a hash (#) when root.
 + `-l [<city, country> | LocateMe]` - switch to instead supply your city and country in a string for location checking (e.g., `"London, UK"`).
     * To have BashWeather check your location via the Mac built-in utility, use `-l LocateMe`.
     * Default is to use your IP address.  Note that this will be inaccurate if using a proxy.
 + `-u <integer>` - how often, in seconds, to wait between weather updates.  Default is 10800 (3 hours).
 + `-s <string>` - a string, like `"(weather updated)"`, to display only when the weather has just been updated.  No default.
 + `-t <integer>` - timeout, in seconds, for any http requests made by BashWeather.  Make this value smaller if you want a shorter delay when no internet is available or is too slow.  Default is 1.
 + `-h` - display the help.
EOF
)
	      echo "$HELP"
	      return 1
              ;;
          \? )
              echo "Invalid option: -$OPTARG" >&2
              ;;
          :  )
              echo "Option -$OPTARG requires an argument." >&2
              return 1
              ;;
      esac
  done
  shift $((OPTIND-1))

  # defaults
  if [ -z "$u" ] ; then u=10800 ; fi
  if [ -z "$c" ] ; then c=\$ ; fi
  if [ -z "$t" ] ; then t=1 ; fi

  local NOW=$(date +%s)

  # 10800 is 3 hours in Unix time--so we download the weather again after 3 hours
  # 3600 is 1 hour
  if [ -z "$LAST_TIME_CHECKED_WEATHER" ] ; then # on startup

      local RESPONSEHOLDER=$(getResponse)

      LAST_TIME_CHECKED_WEATHER=$NOW
      local UPDATED=""
      local ASSIGN_AGAIN=true

  elif [ "$LAST_TIME_CHECKED_WEATHER" -lt $((NOW - u)) ] ; then # because would be int rather than empty string

     local RESPONSEHOLDER=$(getResponse)

     if [ -n "$s" ] ; then
       local UPDATED="$s" # only adds for later updates, not for prompt initialization
     fi
     LAST_TIME_CHECKED_WEATHER=$NOW
     local ASSIGN_AGAIN=true

  else
      local UPDATED=""
  fi

  if [ $ASSIGN_AGAIN ] ; then
    local WEATHERCODE=$(echo "$RESPONSEHOLDER" | grep -o -e '"weather":[^[]*\[[^{]*{[^}]*"id": *[0-9]\{1,3\}' | tail -c 4)
    local SUNRISE=$(echo "$RESPONSEHOLDER" | grep -o -e '"sunrise":[0-9]\{10\}' | tail -c 11)
    local SUNSET=$(echo "$RESPONSEHOLDER" | grep -o -e '"sunset":[0-9]\{10\}' | tail -c 11)

      # consider changing this nested if statement to a `case` statement

      if [[ -n $WEATHERCODE ]] ; then
            if [ "${WEATHERCODE:0:1}" -eq "2" ] ; then
                WEATHERCHAR=$(get_symbol umbrellarain)
            elif [ "${WEATHERCODE:0:1}" -eq "3" ] ; then
                WEATHERCHAR=$(get_symbol umbrella)
            elif [ "${WEATHERCODE:0:1}" -eq "5" ] ; then
                WEATHERCHAR=$(get_symbol umbrellarain)
            elif [ "${WEATHERCODE:0:1}" -eq "6" ] ; then
                WEATHERCHAR=$(get_symbol snowman)
            elif [ "${WEATHERCODE:0:1}" -eq "8" ] ; then
                if [ "$NOW" -lt "$SUNRISE" ] ; then
                  WEATHERCHAR=$(get_symbol moon)
                elif [ "$NOW" -gt "$SUNRISE" -a "$NOW" -lt "$SUNSET" ] ; then
                  if [ "$WEATHERCODE" -eq "804" ] ; then #overcast
                    WEATHERCHAR=$(get_symbol cloud)
                  else
                    WEATHERCHAR=$(get_symbol sun)
                  fi
                elif [ "$NOW" -gt "$SUNSET" ] ; then
                  WEATHERCHAR=$(get_symbol moon)
                fi
            else
	        WEATHERCHAR="$c" # if no weathercode make default character ($)
            fi
      else
          WEATHERCHAR="$c" # if internet dead so no WEATHERCODE
      fi
  else
    if [ -n "$s" ] ; then
        # get rid of $UPDATED from $WEATHERCHAR
        if [ "${WEATHERCHAR:${#WEATHERCHAR} - ${#s}}" == "$s" ] ; then
            WEATHERCHAR="${WEATHERCHAR:0:12}"
        fi
    fi
  fi

  WEATHERCHAR=$(echo -n "$WEATHERCHAR" && echo " $UPDATED" | sed 's/ *$//')
}

runWeather "$@"
