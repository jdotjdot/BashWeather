BashWeather
===========

A Bash script to add regularly updated localized weather icons to your bash prompt.

Pull requests welcome!

Program: BashWeather<br>
Author: J.J.<br>
Email: JJ@jdotjdot.com<br>
Version 1.2<br>

This script makes use of the following tools:
+ [LocateMe](https://github.com/netj/LocateMe) for Mac OS X by Robert Harder
    *  Includes both the source code as well as the pre-compiled XCode project
+ [OpenWeatherMap](http://openweathermap.org)'s excellent weather API
+ [Shellcheck.net](http://www.shellcheck.net/) -- excellent Bash debugging tool!
+ [ip-api.com](http://ip-api.com) for IP geolocation
The accuracy of BashWeather relies on OpenWeatherMap and, if using it, ip-api.com. 

![BashWeather screenshot](https://dl.dropboxusercontent.com/s/kuhg2qfky3y6kvo/bashweather%20screenshot.png)
<!-- ![BashWeather screenshot](https://dl.dropboxusercontent.com/s/fnlza39a2q1ubut/bashweather%20screenshot%202.png) -->

*Screenshots of sample terminal sessions with BashWeather, note the moon*

**Known Issues:**
+ **Believed resolved** Per this [StackOverflow question](http://stackoverflow.com/questions/22922138/terminal-overwriting-same-line-when-too-long?noredirect=1#comment35042608_22922138), you may encounter bugs in certain terminal programs or versions of bash when writing past the end of a line, due to issues with unicode display.  This is believed to be resolved by having removed the "umbrella with rain" character and replaced it with the regular umbrella.

##USAGE
`BashWeather.sh -h` gives the following:

USAGE:
    Add `. [/path/to/]BashWeather.sh [options]` to your `.bashrc`,
    then include `$WEATHERCHAR` in your bash `$PS1` variable somewhere below that.
    If you plan to use the provided `RunLocateMe` binary that makes use of Mac OS X's geolocation feature, make sure that it is located in the same directory as `BashWeather.sh`.
    Alternatively, if you simply wish to return the character, you can use the `-e` flag like `printf "$(. [/path/to/]BashWeather.sh [options] -e )"` to print the weather character.

OPTIONS:
+ `-c <character>` - default character to be displayed in your prompt should the weather not be available for any reason.  Default character is the dollar sign (`$`).  Please note that this will NOT become a hash (`#`) when root.
 + `-l [<city, country> | LocateMe]` - switch to instead supply your city and country in a string for location checking (e.g., `"London, UK"`).
     * To have BashWeather check your location via the Mac built-in utility, use `-l LocateMe`.
     * Default is to use your IP address.  Note that this will be inaccurate if using a proxy.
 + `-u <integer>` - how often, in seconds, to wait between weather updates.  Default is 10800 (3 hours).
 + `-s <string>` - a string, like `"(weather updated)"`, to display only when the weather has just been updated.  No default.
 + `-t <integer>` - timeout, in seconds, for any HTTP requests made by BashWeather.  Make this value smaller if you want a shorter delay when no internet is available or is too slow.  Default is 1.
 + `-e` - echo the resulting character instead. This does _not_ save to `WEATHERCHAR`.
 + `-h` - display the help.

BashWeather will create the following global variables in Bash:
+ `LAST_TIME_CHECKED_WEATHER` - to store the last time the weather was updated
+ `LAT` - latitude
+ `LON` - longitude
+ `WEATHERCHAR` - a variable containing the appropriate weather character for you to include in your bash prompt as you see fit.
