BashWeather
===========

A Bash script to add regularly updated localized weather icons to your bash prompt

Program: BashWeather
Author: J.J.
Email: JJ@jdotjdot.com
Version 1.0

This script makes use of the following tools:
+  [LocateMe](https://github.com/netj/LocateMe) for Mac OS X by Robert Harder
    *  Includes both the source code as well as the pre-compiled XCode project
+ [OpenWeatherMap](http://openweathermap.org)'s excellent weather API
+ [Shellcheck.net](http://www.shellcheck.net/) -- excellent Bash debugging tool!

##USAGE
BashWeather -h gives the following:

USAGE:
    Add `. [/path/to/]BashWeather.sh [options]` to your `.bashrc`,
    then include `$WEATHERCHAR` somewhere in your bash `$PROMPT` variable.
    If you plan to use the provided `RunLocateMe` binary that makes use of Mac OS X's geolocation feature, make sure that it is located in the same directory as `BashWeather.sh`.

OPTIONS:
 + `-c <character>` - default character to be displayed in your prompt should the weather not be available for any reason.  Default character is the interrobang (`‽`)
 + `-l [<city and country> | ip]` - switch to instead supply your city and country in a string for location checking (e.g., `"London, UK"`).
     * To have BashWeather check your location via your IP address instead, supply `-l ip`.
     * Default is to use `LocateMe`.
 + `-u <integer>` - how often, in seconds, to wait between weather updates.  Default is 10800 (3 hours).
 + `-s <string>` - a string, like `"(weather updated)"`, to display only when the weather has just been updated.  No default.
 + `-h` - display the help.


BashWeather will create the following global variables in Bash:
+ `LAST_TIME_CHECKED_WEATHER` - to store the last time the weather was updated
+ `LAT`
+ `LON`
+ `WEATHERCHAR` - this is the final output of the script, a variable containing the appropriate weather character for you to include in your bash prompt as you see fit