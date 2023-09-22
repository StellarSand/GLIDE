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

source /usr/local/lib/GLIDE/common_utils.sh

# Checks disk free space after all files would be downloaded
chkRemSpace() {
  echo "Checking available disk space ..."
  echo -e "This may take a while ...\n"
  iso_size=$(dnldFileSize "$url"/"$iso")
  sha_size=$(dnldFileSize "$url"/"$sha_file")
  total_dnld_size=$(awk -v iso_size="$iso_size" -v sha_size="$sha_size" 'BEGIN {print (iso_size + sha_size) * 1024**2}')
  rem_space=$(($(diskFreeSpace)-"$total_dnld_size"))
}

# Download iso
downloadISO() {
  echo -e "\nDownloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$iso" "$url/${iso}&redirect=1&protocol=https"
  successFail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$sha_file" "$url"/"$sha_file"
  successFail
}

# Check authenticity of downloaded iso
chkAuth() {
  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ "$(sha256sum "$iso")" == "$(cat "$sha_file")" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "ISO downloaded is not authentic.\n"
  fi
}

# Check integrity of downloaded iso
chkInt() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha256sum -c "$sha_file" 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

chkVer "https://www.centos.org/centos-stream/"

cent_stream_ver=$(while read -r
                do
                  awk 'match($0, /path=\/([0-9]*)/, a){print a[1]}' | 
                  # $0 => current line
                  # /path=\/ => search for path=/
                  # [0-9] => matches anything that is a digit.
                  # * => zero or more times
                  # a => store the matched substrings in an array 'a'
                  # a[1] => The array index corresponds to matched string in groups enclosed in (). Here it's ([0-9]*)
                  head -1 # Returns first line of awk output
                done < /tmp/scrape)

iso="CentOS-Stream-${cent_stream_ver}-latest-x86_64-dvd1.iso"
url="https://mirrors.centos.org/mirrorlist?path=/${cent_stream_ver}-stream/BaseOS/x86_64/iso"
sha_file="${iso}.SHA256SUM"
rem_space=""

chkRemSpace

if [ "$rem_space" -ge 0 ]
then
  downloadISO
  downloadSHA
  chkAuth
  chkInt
else
  calcReqSpace "$rem_space"
fi

cleanup

exit 0