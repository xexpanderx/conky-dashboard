# **Conky dashboard for Slackware**

![alt tag](https://raw.githubusercontent.com/xexpanderx/conky-dashboard/master/screenshot.png)

## Dependencies

 - xdotool
 - Font Awesome **Pro** (not tested with Free version)
 - pyowm
 - sbopkg
 - slackpkg+
 - Google Chrome
 - Nvidia proprietary driver
 - Skype
 - OpenWeatherMap API key

## Install

    git clone https://github.com/xexpanderx/conky-dashboard
    mkdir -p ~/.conky/
    cp -r conky-dashboard ~/.conky/
    chmod +x ~/.conky/conky-dashboard/start_conky.sh
    chmod +x ~/.conky/conky-dashboard/slackware_updates.bash

## Configuration

### dashboard.lua
You need to fill in with your OpenWeatherMap API key, City and Country-code in `dashboard.lua` in order to fetch weather information:

    -- ### Api key ###
    api_key="[API_KEY]"
    
    -- ### City ###
    
    city="[CITY]"
    
    -- ### Country code ###
    
    ccode="[COUNTRY_CODE]"
  ### cronjob
  You need to add a cronjob for the scripts that collect updates and weather information. In addition, you need to fill in with the same information as above (API_KEY, CITY and COUNTRY_CODE):

    */5 * * * * ~/.conky/conky-dashboard/slackware_updates.bash -r current --sbopkg --nvidia --kernel --google-chrome --skype > ~/.conky/conky-dashboard/.updates.txt
    */5 * * * * python3 ~/.conky/conky-dashboard/openweather.py --api_key API_KEY --city CITY --ccode COUNTRY_CODE --get_weather_icon --get_temp_c > ~/.conky/conky-dashboard/.weather.txt
 ## Run
 

    ~/.conky/conky-dashboard/start_conky.sh
