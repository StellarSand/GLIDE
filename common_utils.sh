#!/bin/bash

successFail() {

if [ $? -eq 0 ]
then
	echo -e "DONE.\n"
else
	echo -e "Some error occurred performing the task.\n"
fi

}

execPerm() {
  if [ ! -x "$1" ]
  then
  	chmod +x "$1"
  fi
}

downloadDir() {
  cat "$HOME/.config/GLIDE/dnld_dir"
}

GKey() {
  grep "$1" conf/keys | sed s/"$1"=//
}

cleanup() {
  echo -e "Removing temporary files ...\n"
  rm /tmp/scrape
  successFail
}