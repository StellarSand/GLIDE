#!/usr/bin/env bash

source /usr/local/lib/GLIDE/common_utils.sh

Distro=""
DefDnldDir=$(xdg-user-dir DOWNLOAD)
ConfigDir="$HOME/.config/GLIDE"
ConfigFile="$ConfigDir/dnld_dir"
DistroScriptsDir="/usr/local/lib/GLIDE/distros"

hasCommand() {
if ! (command -v "$1" > /dev/null)
then
  echo -e "\n$1 package does not exist. Please install it first and try again.\n"
  echo -e "Exiting script ...\n"
  exit 1
fi
}

# Show usage
usage() {

cat << EOF

Usage:
glide -n <distro name>
glide -n <distro name> -d <directory>

Description:
Script to download latest GNU/Linux ISO.

Available options:
 -h,  --help            Show this help message
 -l,  --list            Show available distro list
 -D,  --default-dir     Change default download directory
 -d,  --directory       Change directory for current download only
 -n,  --name            Distro name (from available list)

Examples:
glide -n ubuntu
glide -n ubuntu -d /home/user/Desktop

EOF

}

# Show list of available distros
listDistros() {

cat << EOF

Available distros:

arch
centosstream
debian
endeavouros
fedora
kali
linuxmint
manjaro
ubuntu

EOF

}

# Start script

# Check config directory
if [ ! -d "$ConfigDir" ]
then
		mkdir "$ConfigDir"
fi

# Check config file
if [ ! -f "$ConfigFile" ]
then
  echo -e "$DefDnldDir" > "$ConfigFile"
  echo -e "Default download directory is set to $DefDnldDir"
fi

# Check download directory
if [ ! -d "$DefDnldDir" ]
then
  echo -e "Set a default directory to download files.\n"
  echo -e "Try 'glide -h' for more information.\n"
  echo -e "Exiting script ...\n"
  exit 1
fi

# Check curl package
hasCommand "curl"

# Check GPG package
hasCommand "gpg"

# If no options are provided, print usage
if [ $# -eq 0 ]
then
  usage
  exit 0
fi

# Process options
while [ $# -gt 0 ]
do
case "$1" in

	-h | --help)
		usage
		exit 0
	;;

	-l | --list)
		listDistros
		exit 0
	;;

	-D | --default-dir)
	  if [ $# -gt 1 ]
    then
      shift
      DefDnldDir=$1
      echo "$DefDnldDir" > "$ConfigFile"
      successFail
      echo -e "All files will be downloaded in $DefDnldDir"
    else
      echo -e "\nInvalid option: $1\n"
      echo -e "The -D or --default-dir option must be used alone.\n"
      echo -e "Try 'glide -h' for more information.\n"
      exit 1
    fi
	;;

  -d | --directory)
    if [ $# -gt 1 ]
    then
      shift
      CurrDnldDir=$1
      if [ ! -d "$CurrDnldDir" ]
      then
        echo -e "\n$CurrDnldDir does not exist.\n"
        echo -e "Exiting script ...\n"
        exit 1
      else
        echo "$CurrDnldDir" > /tmp/curr_dnld_dir
      fi
    else
      echo -e "\nInvalid option: $1\n"
      echo -e "The -d or --directory option must be followed by a directory path.\n"
      echo -e "Try 'glide -h' for more information.\n"
      exit 1
    fi
  ;;

	-n | --name)
	  if [ $# -gt 1 ]
	  then
      shift
      Distro=$1
    else
      echo -e "\nInvalid option: $1\n"
      echo -e "The -n or --name option must be followed by a distro name.\n"
      echo -e "Try 'glide -h' for more information.\n"
      exit 1
    fi
	;;

	*)
		echo -e "\nInvalid option: $1\n"
		echo -e "Try 'glide -h' for more information.\n"
		exit 1
	;;

esac
shift
done

# Perform actual downloads
# Keep scripts separate for easier & better maintenance
if [ -n "$Distro" ] # Only run this if script has "-n" input
then
  if [ -f $DistroScriptsDir/"$Distro".sh ]
  then
    execPerm $DistroScriptsDir/"$Distro".sh
    $DistroScriptsDir/"$Distro".sh
  else
    echo -e "\nInvalid distro name\n"
    echo -e "Try 'glide -l' to see the list of available distros.\n"
    exit 1
  fi
fi

exit 0
