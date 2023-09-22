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

chkLTS(){
  echo -e "\nSelect whether to download LTS or Non-LTS"
  echo -e "1. LTS\n2. Non-LTS\n"
  read -p "Enter 1 or 2: " lts

  if [ "$lts" -eq 1 ]
  then
    is_lts=true
  fi
}

# Checks disk free space after all files would be downloaded
chkRemSpace() {
  echo -e "\nChecking available disk space ..."
  echo -e "This may take a while ...\n"
  iso_size=$(dnldFileSize "$url"/"$iso")
  sha_size=$(dnldFileSize "$url"/"$sha_file")
  gpg_size=$(dnldFileSize "$url"/"$gpg_file")
  total_dnld_size=$(awk -v iso_size="$iso_size" -v sha_size="$sha_size" -v gpg_size="$gpg_size" 'BEGIN {print iso_size + sha_size + gpg_size}')
  rem_space=$(($(diskFreeSpace)-"$total_dnld_size"))
}

# Download iso
downloadISO() {
  echo -e "\nDownloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$iso" "$url"/"$iso"
  successFail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$sha_file" "$url"/"$sha_file"
  successFail
}

# Download GPG file
downloadGPG() {
  echo -e "\nDownloading GPG file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$gpg_file" "$url"/"$gpg_file"
  successFail
}

# Check authenticity of downloaded iso
chkAuth() {
  echo -e "\nAdding GPG keys ...\n"
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$ubuntu_gkey"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpg --keyid-format long --verify "$gpg_file" "$sha_file"
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

is_lts=false
sha_file="SHA256SUMS"
gpg_file="${sha_file}.gpg"
ubuntu_gkey=$(GKey Ubuntu)
rem_space=""

chkLTS

chkVer "https://ubuntu.com/download/desktop"

if $is_lts
then
  ubuntu_ver=$(while read -r
              do
                awk 'match($0, /Ubuntu ([.0-9]*) LTS/, a){print a[1]}' |
                # $0 => current line
                # /Ubuntu  => search for Ubuntu
                # [.0-9] => matches anything that is a dot or digit.
                # * => zero or more times
                # LTS/ => make sure there's LTS after the dots/digits
                # a => store the matched substrings in an array 'a'
                # a[1] => The array index corresponds to matched string in groups enclosed in (). Here it's ([.0-9]*) 
                head -1 # Returns first line of awk output
              done < /tmp/scrape)
else
  ubuntu_ver=$(while read -r
              do
                awk 'match($0, /Ubuntu ([.0-9]*)</, a){print a[1]}'
                # $0 => current line
                # /Ubuntu  => search for Ubuntu
                # [.0-9] => matches anything that is a dot or digit.
                # * => zero or more times
                # </ => make sure there's < after the dots/digits
                # a => store the matched substrings in an array 'a'
                # a[1] => The array index corresponds to matched string in groups enclosed in (). Here it's ([.0-9]*)
              done < /tmp/scrape)
fi

iso="ubuntu-${ubuntu_ver}-desktop-amd64.iso"
url="https://releases.ubuntu.com/${ubuntu_ver}"

chkRemSpace

if [ "$rem_space" -ge 0 ]
then
  downloadISO
  downloadSHA
  downloadGPG
  chkAuth
  chkInt
else
  calcReqSpace "$rem_space"
fi

cleanup

exit 0