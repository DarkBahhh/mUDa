#!/bin/bash
### The mUDa.sh program assist you to make some little modifications on the
### Ubuntu Desktop system for specific usages. Specific usages are contained in
### modules modifying the system. Modules are callable independently and could
### need some dependencies.
### Only tested on Ubuntu Desktop 18 LTS.
###
### Modules:
###     - Sonmax:
###         This module allow you to boost the sound of the computer (!! sound
###         quality decrease !!). By default this module boost sound to 150%.
###     - Luminomax:
###         This module allow you to boost the luminosity of the screen (!!
###         energetic consummation increase !!), the module modify brightness
###         and gamma with xrandr to increase the luminomaxsity.
###     - nVPN:
###         This module is used with the NordVPN CLI client app to activate the
###         VPN connection. The connection can be for P2P or PublicNetwork and
###         killSwitch module is activated on the system. The connection's
###         country is configurable by the user (by default, NordVPN CLI app
###         choose the better server) the user can change default country in the
###         program variable.
###
###
### Use "mUDa.sh --help" to print Input and Ouput details.
###

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#                         Below is the variables section.
#
#          You can edit the variables section only if you know the variable
#                                  correspond to!
#
#          With editing variables you will change some modules behavior!
#       Variable with a name starting with 'default' expect Ubuntu default value!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Modules vars:
#    Sonmax:
over_sound="150%"
default_sound="100%"
#    Luminomax:
gui_card="eDP-1"
over_brightness=2
over_gamma="0.5:1.0:1.0"
default_brightness=1
default_gamma="1.0:1.0:1.0"
#    nVPN:
nvpnDefaultCountry=""

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

# Program vars:
stateFile_name='mUDa.log'
stateFile_path='/tmp'

# Functions:
#    Script usage:
usage(){
	  printf "Help:\nFormat: \"mUDa.sh Module ModuleParams\"\n"
	  printf "With Module is:\n"
	  printf "\tsonmax                : Module to maximize sound volume;\n"
	  printf "\tluminomax             : Module to maximize the screen luminosity;\n"
	  printf "\tnvpn                  : Module to easy use NordVPN CLI commands;\n"
	  printf "\tstate                 : Module to display other modules state;\n"
	  printf "\nWith ModuleParams is:\n"
	  printf "\tWhere Module is sonmax:\n"
	  printf "\t\tstart|stop                           : Start or stop the module;\n"
	  printf "\tWhere Module is luminomax:\n"
	  printf "\t\tstart|stop                           : Start or stop the module;\n"
	  printf "\tWhere Module is nvpn:\n"
	  printf "\t\tRegister <UserName> <UserPass>       : Login to NordVPN with <UserName> as user account and <UserPass> as user password;\n"
	  printf "\t\tCountList                            : Return countries available with NordVPN;\n"
	  printf "\t\tstart P2P|PUB [<CountryName>]        : Start a connection to NordVPN servers group peer2peer or Standard servers (this enable NordVPN KillSwitch too), optionnaly set a country name;\n"
	  printf "\t\tstop                                 : Stop connection to NordVPN and disable NordVPN KillSwitch;\n"
	  printf "\nScript ErrorCode:\n"
	  printf "\t1          : Error with Module parameter;\n"
	  printf "\t2          : Error with specific module parameters (Module parameter is accepted);\n"
	  printf "\t3          : Error in NordVPN moudle connexion parameters;\n"
	  printf "\t4          : Unkown error in system command (xrandr, nordvpn ...);\n"
	  printf "\t5          : Error in NordVPN login (more a warning than an error);\n"
	  printf "\t6          : Error with NordVPN CountryName parameters;\n"
}

#    Show modules states:
state(){
    state_output=''
    while read line; do
	      md=$(echo $line | cut -d ' ' -f 1)
	      bool=$(echo $line | cut -d ' ' -f 2)
        if [[ $bool -eq 0 ]]; then
            state_output=$state_output'\n'$md'     OFF'
        else
            state_output=$state_output'\n'$md'     ON'
        fi
    done <$stateFile
    echo -e $state_output
}

#    Sonmax module:
sonmax(){
    if [[ $1 == 'start' ]]; then
        pactl -- set-sink-volume 0 $over_sound
	      if [[ $? -eq 0 ]]; then
            sed -i 's/Sonmax 0/Sonmax 1/g' $stateFile
	      else
	          exit 4
        fi
    elif [[ $1 == 'stop' ]]; then
        pactl -- set-sink-volume 0 $default_sound
	      if [[ $? -eq 0 ]]; then
            sed -i 's/Sonmax 1/Sonmax 0/g' $stateFile
	      else
	          exit 4
        fi
    else
        exit 2
    fi
}

#    Luminomax module:
luminomax(){
    if [[ $1 == 'start' ]]; then
	      xrandr --output $gui_card --brightness $over_brightness
	      xrandr --output $gui_card --gamma $over_gamma
	      if [[ $? -eq 0 ]]; then
            sed -i 's/Luminomax 0/Luminomax 1/g' $stateFile
	      else
	          exit 4
        fi
    elif [[ $1 == 'stop' ]]; then
	      xrandr --output $gui_card --brightness $default_brightness
	      xrandr --output $gui_card --gamma $default_gamma
	      if [[ $? -eq 0 ]]; then
            sed -i 's/Luminomax 1/Luminomax 0/g' $stateFile
	      else
	          exit 4
        fi
    else
        exit 2
    fi
}

#    NordVPN module:
nvpnRegister(){
    if [[ $1 == 'set' ]]; then
        nordvpn login -u $2 -p $3
        if [[ $? -ne 0 ]];then
            exit 5
        fi
    elif [[ $1 == 'info' ]];then
        nvpnInfo=$(nordvpn account)
        if [[ $? -eq 0 ]];then
            echo -e $nvpnInfo
        else
            exit 4
        fi
    fi
}

nvpnCountryList(){
    clist=$(nordvpn countries)
    if [[ $? -eq 0 ]]; then
        echo -e $clist
    fi
}

nvpnP2P(){
    if [[ $? -eq 1 ]]; then
        nvpnStop
    fi
    nordvpn connect -g P2P $nvpn_Country && nordvpn set killswitch on
	  if [[ $? -eq 0 ]]; then
        sed -i 's/nVPNp2p 0/nVPNp2p 1/g' $stateFile
        sed -i 's/nVPNpub 1/nVPNpub 0/g' $stateFile
    elif [[ $? -eq 1 ]]; then
        exit 6
	  else
	      exit 4
    fi
}

nvpnPublicNet(){
    if [[ $? -eq 1 ]]; then
        nvpnStop
    fi
    nordvpn connect -g Standard_VPN_Servers $nvpn_Country && nordvpn set killswitch on
	  if [[ $? -eq 0 ]]; then
        sed -i 's/nVPNpub 0/nVPNpub 1/g' $stateFile
        sed -i 's/nVPNp2p 1/nVPNp2p 0/g' $stateFile
    elif [[ $? -eq 1 ]]; then
        exit 6
	  else
	      exit 4
    fi
}

nvpnStop(){
    nordvpn set killswitch off && nordvpn disconnect
	  if [[ $? -eq 0 ]]; then
        sed -i 's/nVPNpub 1/nVPNpub 0/g' $stateFile
        sed -i 's/nVPNp2p 1/nVPNp2p 0/g' $stateFile
	  else
	      exit 4
    fi
}

nvpn(){
    if [[ $1 == 'Register' ]]; then
        shift
        nvpnRegister $@
    elif [[ $1 == 'CountList' ]]; then
        nvpnCountryList
    elif [[ $1 == 'start' ]]; then
        if [[ -n $3 ]]; then
            nvpn_Country=$3
        else
            nvpn_Country=$nvpnDefaultCountry
        fi
        if [[ $2 == 'P2P' ]]; then
            nvpnP2P
        elif [[ $2 == 'PUB' ]]; then
            nvpnPublicNet
        else
            exit 3
        fi
    elif [[ $1 == 'stop' ]]; then
        nvpnStop
    else
        exit 2
    fi
}


# Main:
stateFile=$stateFile_path'/'$stateFile_name
stateFile_template='Sonmax 0\nLuminomax 0\nnVPNp2p 0\nnVPNpub 0'
if [[ ! -f $stateFile ]]; then
    echo -e $stateFile_template > $stateFile
fi
case $module in
    sonmax) sonmax $@;;
    luminomax) luminomax $@;;
    nvpn) nvpn $@;;
    state) state ;;
    *) usage ;
       exit 1;;
esac
