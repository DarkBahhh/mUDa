#!/bin/bash
### The mUDa.sh program assist you to make some little modifications on the
### Ubuntu Desktop system for specific usages. Specific usages are contained in
### modules modifying the system. Modules are callable independently and could
### need some dependencies.
### Only tested on Ubuntu Desktop 18.
###
### Modules:
###     - Son:
###         This module allow you to boost the sound of the computer (!! sound
###         quality decrease !!). By default this module boost sound to 150%.
###     - Lumino:
###         This module allow you to boost the luminosity of the screen (!!
###         energetic consummation increase !!), the module modify brightness
###         and gamma with xrandr to increase the luminosity.
###     - nVPN:
###         This module is used with the NordVPN client app to activate the
###         KillSwitch module on the computer (vpn connection are directly set
###         with gnome network desktop tool).

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#                         Below is the variable section.
#
#          You can edit the variable section only if you know the variable
#                                  correspond to!
#
#          With editing variables you will change some modules behavior!
#       Variable with a name starting with 'default' are Ubuntu default value!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Vars:
#    Son:
over_sound="150%"
default_sound="100%"
#    Lumino:
#gui_card="eDP-1"
gui_card="Virtual-0"
over_brightness=2
over_gamma="0.5:1.0:1.0"
default_brightness=1
default_gamma="1.0:1.0:1.0"

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#     DON'T EDIT      DON'T EDIT     DON'T EDIT     DON'T EDIT     DON'T EDIT
#
#      Below is the main code of the program, DON'T EDIT, let developers do it
#
#     DON'T EDIT      DON'T EDIT     DON'T EDIT     DON'T EDIT     DON'T EDIT
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Input:
module=$1
shift
task=$1

# Functions:
help(){
    echo Contact admin
}

#    Sound module:
son(){
    if [[ $task == 'start' ]]; then
        pactl -- set-sink-volume 0 $over_sound
    elif [[ $task == 'stop' ]]; then
        pactl -- set-sink-volume 0 $default_sound
    else
        exit 3
    fi
}

#    Lumino module:
lumino(){
    if [[ $task == 'start' ]]; then
			  xrandr --output $gui_card --brightness $over_brightness
			  xrandr --output $gui_card --gamma $over_gamma
    elif [[ $task == 'stop' ]]; then
			  xrandr --output $gui_card --brightness $default_brightness
			  xrandr --output $gui_card --gamma $default_gamma
    else
        exit 3
    fi
}

#    NordVPN module:
nvpn(){
    if [[ $task == 'start' ]]; then
	      nordvpn set killswitch enabled
    elif [[ $task == 'stop' ]]; then
        nordvpn set killswitch disabled
    else
        exit 3
    fi
}

# Main:
case $module in
    son) son ;;
    lumino) lumino ;;
    vpn) nvpn ;;
    *) help ;;
esac
