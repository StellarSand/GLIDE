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

echo "Installing ..."
sudo cp glide.sh /usr/bin/glide
if [ ! -d /usr/local/lib/GLIDE ]
then
  sudo mkdir /usr/local/lib/GLIDE
fi
sudo cp common_utils.sh /usr/local/lib/GLIDE/
sudo cp -r distros /usr/local/lib/GLIDE/
sudo cp -r conf /usr/local/lib/GLIDE/
successFail

echo "Fixing permissions ..."
sudo chmod +x /usr/bin/glide
sudo chmod +x /usr/local/lib/GLIDE/common_utils.sh
sudo chmod +x /usr/local/lib/GLIDE/distros/*.sh
successFail

glide -h

exit 0