#!/usr/bin/env bash

ScrapeFile="/tmp/scrape"
CurrDnldDir="/tmp/curr_dnld_dir"

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
  curl -s "$1" > $ScrapeFile
}

# Download directory
downloadDir() {
  if [ -f $CurrDnldDir ]
  then
    cat "$CurrDnldDir"
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
  RemSpace=$1
  ReqSpace=${RemSpace//-/} # {variable//search/replace}; absolute value of remaining space
  if [ "$ReqSpace" -le 1024 ]
  then
    Unit="B"
  elif [ "$ReqSpace" -gt 1024 ] && [ "$ReqSpace" -le $((1024**2)) ]
  then
    ReqSpace=$(("$ReqSpace"/1024))
    Unit="KB"
  elif [ "$ReqSpace" -gt $((1024**2)) ] && [ "$ReqSpace" -le $((1024**3)) ]
  then
    ReqSpace=$(("$ReqSpace"/1024**2))
    Unit="MB"
  else
    ReqSpace=$(("$ReqSpace"/1024**3))
    Unit="GB"
  fi
  echo "Not enough disk space to download."
  echo "Please clear up $ReqSpace $Unit and try again."
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
  rm $ScrapeFile
  if [ -f $CurrDnldDir ]
  then
    rm $CurrDnldDir
  fi
  successFail
}