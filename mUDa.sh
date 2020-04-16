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
#       Variable with a name starting with 'default' expect Ubuntu default value!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Modules vars:
#    Son:
over_sound="150%"
default_sound="100%"
#    Lumino:
gui_card="eDP-1"
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

# Program vars:
stateFile_name='mUDa.log'
stateFile_path='/tmp'

# Functions:
help(){
    echo Contact admin
    exit 2
}

#    Show modules states:
state(){
    state_output=''
    while read line; do
	      md=$(echo $line | cut -d ' ' -f 1)
	      bool=$(echo $line | cut -d ' ' -f 2)
        if [[ $bool == 0 ]]; then
            state_output=$state_output'\n'$md'     OFF'
        else
            state_output=$state_output'\n'$md'     ON'
        fi
    done <$stateFile
    echo -e $state_output
}

#    Sound module:
son(){
    if [[ $task == 'start' ]]; then
        pactl -- set-sink-volume 0 $over_sound
	      if [[ $? -eq 0 ]]; then
            sed -i 's/Son 0/Son 1/g' $stateFile
	      else
	          exit 4
        fi
    elif [[ $task == 'stop' ]]; then
        pactl -- set-sink-volume 0 $default_sound
	      if [[ $? -eq 0 ]]; then
            sed -i 's/Son 1/Son 0/g' $stateFile
	      else
	          exit 4
        fi
    else
        exit 3
    fi
}

#    Lumino module:
lumino(){
    if [[ $task == 'start' ]]; then
	      xrandr --output $gui_card --brightness $over_brightness
	      xrandr --output $gui_card --gamma $over_gamma
	      if [[ $? -eq 0 ]]; then
            sed -i 's/Lumino 0/Lumino 1/g' $stateFile
	      else
	          exit 4
        fi
    elif [[ $task == 'stop' ]]; then
	      xrandr --output $gui_card --brightness $default_brightness
	      xrandr --output $gui_card --gamma $default_gamma
	      if [[ $? -eq 0 ]]; then
            sed -i 's/Lumino 1/Lumino 0/g' $stateFile
	      else
	          exit 4
        fi
    else
        exit 3
    fi
}

#    NordVPN module:
nvpn(){
    if [[ $task == 'start' ]]; then
	      nordvpn set killswitch enabled
	      if [[ $? -eq 0 ]]; then
            sed -i 's/nVPN 0/nVPN 1/g' $stateFile
	      else
	          exit 4
        fi
    elif [[ $task == 'stop' ]]; then
        nordvpn set killswitch disabled
	      if [[ $? -eq 0 ]]; then
            sed -i 's/nVPN 1/nVPN 0/g' $stateFile
	      else
	          exit 4
        fi
    else
        exit 3
    fi
}

# Main:
stateFile=$stateFile_path'/'$stateFile_name
stateFile_template='Son 0\nLumino 0\nnVPN 0'
if [[ ! -f $stateFile ]]; then
    echo -e $stateFile_template > $stateFile
fi
case $module in
    son) son ;;
    lumino) lumino ;;
    vpn) nvpn ;;
    state) state ;;
    *) help ;;
esac
