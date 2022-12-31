#!/usr/bin/env bash

scrapeFile="/tmp/scrape"
currDnldDir="/tmp/curr_dnld_dir"

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
  echo -e "Checking for latest version ..."
  echo -e "This may take a while ...\n"
  curl -s "$1" > $scrapeFile
}

# Download directory
downloadDir() {
  if [ -f $currDnldDir ]
  then
    cat "$currDnldDir"
  else
  cat "$HOME/.config/GLIDE/dnld_dir"
  fi
}

# GPG key
GKey() {
  grep "$1" /usr/local/lib/GLIDE/conf/keys | sed s/"$1"=//
}

# Remove temporary files
cleanup() {
  echo -e "Removing temporary files ...\n"
  rm $scrapeFile
  rm $currDnldDir
  successFail
}