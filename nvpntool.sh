#!/bin/bash

# Program vars:
defaultCountry=''

usage(){
	  printf "Usage of $0\nFormat: \"$PWD/$0 [option] task parameters\"\n"
	  printf "List of tasks with their parameters:\n"
	  printf "\tregister on <UserName> <UserPass>   : Login to NordVPN with parameters <UserName> as user account and <UserPass> as user password;\n"
	  printf "\tregister off                         : Logout the NordVPN account;\n"
	  printf "\tregister info                        : Return the actual Login stae;\n"
	  printf "\tp2p                                  : Start a connection to a NordVPN servers in \"peer2peer group\" (this enable NordVPN KillSwitch too);\n"
	  printf "\tstd                                  : Start a connection to a NordVPN servers in \"Standard servers\" group (this enable NordVPN KillSwitch too);\n"
	  printf "\tstop                                 : Stop connection to NordVPN and disable NordVPN KillSwitch;\n"
	  printf "\tlistcountries                        : Return countries available with NordVPN;\n"
	  printf "\tstate                                : Return the connection state;\n"
	  printf "\nList of options:\n"
	  printf "\t-c | --country <name>                : Set a country name for the VPN connection;\n"
	  printf "\t-h | --help                          : Return this help message;\n"
	  printf "\nScript ErrorCode:\n"
	  printf "\t1          : Error with the \"task\" argument;\n"
	  printf "\t2          : Error in parameters of the task (the task is accepted);\n"
	  printf "\t3          : Error in syntax, see \"Format:\";\n"
	  printf "\t4          : Unkown error in nordvpn command ;\n"
	  printf "\t5          : Error in NordVPN login (more a warning than an error);\n"
	  printf "\t6          : Error with option \"--country\", it's not an available country (use task \"listcountry\" to get country list);\n"
}

register(){
    if [[ $1 == 'info' ]];then
        nvpnInfo=$(nordvpn account)
        if [[ $? -eq 0 ]];then
            echo -e $nvpnInfo
        else
            exit 4
        fi
    elif [[ $1 == 'on' ]]; then
        nordvpn login -u $2 -p $3
        if [[ $? -ne 0 ]];then
            exit 5
        fi
    elif [[ $1 == 'off' ]]; then
        nordvpn logout
    else
        exit 2
    fi
}

listcountries(){
    clist=$(nordvpn countries)
    if [[ $? -eq 0 ]]; then
        echo -e $clist
    else
        exit 4
    fi
}

p2pconn(){
    nordvpn connect -g P2P $country && nordvpn set killswitch on
	  if [[ $? -eq 0 ]]; then
        exit 0
    elif [[ $? -eq 1 ]]; then
        exit 6
	  else
	      exit 4
    fi
}

stdconn(){
    nordvpn connect -g Standard_VPN_Servers $country && \
        nordvpn set killswitch on
	  if [[ $? -eq 0 ]]; then
        exit 0
    elif [[ $? -eq 1 ]]; then
        exit 6
	  else
	      exit 4
    fi
}

stopconn(){
    nordvpn set killswitch off && nordvpn disconnect
	  if [[ $? -eq 0 ]]; then
        exit 0
	  else
	      exit 4
    fi
}


# Main:
while true ; do
    if grep -e ^- <<< $1; then
        case $1 in
            -h|--help) usage;
                       exit 0;;
            -c|--country) country=$2;
                          shift;
                          shift;;
            *) echo "Option \"$1\" is not an option of $0";
               echo "Use $PWD/$0 --help to see usage.";
               exit 2;;
        esac
    else
        break
    fi
done
if [[ $# -eq 0 ]]; then
    echo "Use $PWD/$0 --help to see usage."
    exit 1
fi
for param in $@; do
    if grep -e ^- <<< $param; then
        echo "Syntax error with \"$param\"."
        echo "Use $PWD/$0 --help to see usage."
        exit 3
    fi
done
case $1 in
    register) shift;
              register $@;;
    p2p) p2pconn;;
    std) stdconn;;
    stop) stopconn;;
    listcountries) listcountries;;
    state) nordvpn status;;
    *) echo "Parameter \"$1\" is not a parameter of $0";
       echo "Use $PWD/$0 --help to see usage.";
       exit 1;;
esac
