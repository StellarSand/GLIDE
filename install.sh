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

successFail() {
	if [ $? -eq 0 ]
	then
		echo -e "Done.\n"
	else
		echo -e "Some error occurred performing the task.\n"
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