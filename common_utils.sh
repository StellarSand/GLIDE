#!/usr/bin/env bash

# Copyright (C) 2023-present StellarSand

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

scrape_file="/tmp/scrape"
curr_dnld_dir="/tmp/curr_dnld_dir"

successFail() {
  if [ $? -eq 0 ]
  then
    echo -e "Done.\n"
  else
    echo -e "Some error occurred performing the task.\n"
    exit 1
  fi
}

# Executable permission
execPerm() {
  if [ ! -x "$1" ]
  then
  	chmod +x "$1"
  fi
}

# Check for latest version
chkVer() {
  echo -e "\nChecking for latest version ..."
  echo -e "This may take a while ...\n"
  curl -s "$1" > $scrape_file
}

# Download directory
downloadDir() {
  if [ -f $curr_dnld_dir ]
  then
    cat "$curr_dnld_dir"
  else
    cat "$HOME/.config/GLIDE/dnld_dir"
  fi
}

# Check disk free space in bytes
diskFreeSpace() {
  df -B 1 "$(downloadDir)" | awk 'NR==2{print $4}'
}

# Calculate required space if remaining space is less than 0
calcReqSpace() {
  rem_space=$1
  req_space=${rem_space//-/} # {variable//search/replace}; absolute value of remaining space
  if [ "$req_space" -le 1024 ]
  then
    Unit="B"
  elif [ "$req_space" -gt 1024 ] && [ "$req_space" -le $((1024**2)) ]
  then
    req_space=$(("$req_space"/1024))
    Unit="KB"
  elif [ "$req_space" -gt $((1024**2)) ] && [ "$req_space" -le $((1024**3)) ]
  then
    req_space=$(("$req_space"/1024**2))
    Unit="MB"
  else
    req_space=$(("$req_space"/1024**3))
    Unit="GB"
  fi
  echo "Not enough disk space to download."
  echo "Please clear up $req_space $Unit and try again."
  echo -e "Exiting script ...\n"
  exit 1
}

# Check download files size
dnldFileSize() {
  curl -sL --head "$1" | grep -i "Content-Length" | awk '{print $2}'
}

# GPG key
GKey() {
  grep "$1" /usr/local/lib/GLIDE/conf/keys | sed s/"$1"=//
}

# Remove temporary files
cleanup() {
  echo -e "Removing temporary files ...\n"
  rm $scrape_file
  if [ -f $curr_dnld_dir ]
  then
    rm $curr_dnld_dir
  fi
  successFail
}