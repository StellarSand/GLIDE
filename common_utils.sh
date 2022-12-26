#!/bin/bash

success_fail() {

if [ $? -eq 0 ]
then
	echo -e "DONE.\n"
else
	echo -e "Some error occurred performing the task.\n"
fi

}

exec_perm() {
  if [ ! -x "$1" ]
  then
  	chmod +x "$1"
  fi
}

DownloadDir() {
  cat "$HOME/.config/GLIDE/dnld_dir"
}

version() {
  grep "$1" conf/versions | sed s/"$1"=//
}

GKey() {
  grep "$1" conf/keys | sed s/"$1"=//
}