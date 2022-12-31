#!/usr/bin/env bash

successFail() {
if [ $? -eq 0 ]
then
	echo -e "\nDone.\n"
else
	echo -e "\nSome error occurred performing the task.\n"
	exit 1
fi
}

echo "Uninstalling ..."
sudo rm /usr/bin/glide
sudo rm -rf /usr/local/lib/GLIDE
sudo rm -rf "$HOME"/.config/GLIDE
successFail

exit 0