#!/usr/bin/env bash

source /usr/local/lib/GLIDE/common_utils.sh

hasCommand() {
if ! (command -v "$1" > /dev/null)
then
  echo -e "\n$1 package does not exist. Please install it first and try again."
  echo -e "Exiting script ...\n"
  exit 1
fi
}

# Show usage
usage() {

cat << EOF

Usage:
glide <distro name>
glide <distro name> -d <directory>

Description:
Download the latest ISO images for various GNU/Linux distributions directly from the terminal.

Available options:
 -h,  --help            Show this help message
 -l,  --list            Show available distro list
 -D,  --default-dir     Change default download directory
 -d,  --directory       Change directory for current download only

Examples:
glide ubuntu
glide ubuntu -d /home/user/Desktop

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

hasCommand "curl"
hasCommand "gpg"

distro=""
def_dnld_dir=$(xdg-user-dir DOWNLOAD)
config_dir="$HOME/.config/GLIDE"
config_file="$config_dir/dnld_dir"
distro_scripts_dir="/usr/local/lib/GLIDE/distros"

# Check config directory
if [ ! -d "$config_dir" ]
then
		mkdir "$config_dir"
fi

# Check config file
if [ ! -f "$config_file" ]
then
  echo "$def_dnld_dir" > "$config_file"
  echo "Default download directory is set to $def_dnld_dir"
fi

# Check download directory
if [ ! -d "$def_dnld_dir" ]
then
  echo -e "\nSet a default directory to download files."
  echo "Try 'glide -h' for more information."
  echo -e "Exiting script ...\n"
  exit 1
fi

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
        if [ ! -d "$2" ]
        then
          echo -e "\n$2 does not exist."
          echo -e "Exiting script ...\n"
          exit 1
        else
          echo "$2" > "$config_file"
          successFail
          echo -e "All files will be downloaded in $2\n"
          shift
        fi
      else
        echo -e "\nThe -D or --default-dir option must be followed by a directory path."
        echo -e "Try 'glide -h' for more information.\n"
        exit 1
      fi
    ;;

    -d | --directory)
      if [ $# -gt 1 ]
      then
        if [ ! -d "$2" ]
        then
          echo -e "\n$2 does not exist."
          echo -e "Exiting script ...\n"
          exit 1
        else
          echo "$2" > /tmp/curr_dnld_dir
          shift
        fi
      else
        echo -e "\nThe -d or --directory option must be followed by a directory path."
        echo -e "Try 'glide -h' for more information.\n"
        exit 1
      fi
    ;;

    -*)
      echo -e "\nInvalid option: $1"
      echo -e "Try 'glide -h' for more information.\n"
      exit 1
    ;;

    *)
      distro=$1
    ;;


  esac
  shift
done

# Perform actual downloads
# Keep scripts separate for easier & better maintenance
if [ -n "$distro" ] # Only run this if script has "-n" input
then
  if [ -f $distro_scripts_dir/"$distro".sh ]
  then
    execPerm $distro_scripts_dir/"$distro".sh
    $distro_scripts_dir/"$distro".sh
  else
    echo -e "\nInvalid distro name."
    echo -e "Try 'glide -l' to see the list of available distros.\n"
    exit 1
  fi
fi

exit 0
