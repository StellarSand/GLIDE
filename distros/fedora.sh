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
  checksum_size=$(dnldFileSize "$checksum_url"/"$checksum_file")
  gpg_size=$(dnldFileSize "$gpg_url"/"$gpg_file")
  total_dnld_size=$(awk -v iso_size="$iso_size" -v checksum_size="$checksum_size" -v gpg_size="$gpg_size" 'BEGIN {print iso_size + checksum_size + gpg_size}')
  rem_space=$(($(diskFreeSpace)-"$total_dnld_size"))
}

# Download iso
downloadISO() {
  echo -e "\nDownloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$iso" "$url"/"$iso"
  successFail
}

# Download checksum_file
downloadChecksum() {
  echo -e "\nDownloading checksum to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$checksum_file" "$checksum_url"/"$checksum_file"
  successFail
}

# Download GPG file
downloadGPG() {
  echo -e "\nDownloading GPG file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$gpg_file" "$gpg_url"/"$gpg_file"
  successFail
}

chkAuth() {
  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpgv --keyring ./fedora.gpg *-CHECKSUM
}

chkInt() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha256sum -c *-CHECKSUM 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

chkVer "https://alt.fedoraproject.org/"

temp_ver=$(while read -r
          do
            awk 'match($0, /x86_64-([0-9]*)-([.0-9]*).iso/, a){print a[1] "\n" a[2]}'
            # $0 => current line
            # /x86_64- => search for x86_64-
            # [0-9] => matches anything that is a digit.
            # * => zero or more times
            # a => store the matched substrings in an array 'a'
            # a[1] => Stored the matched string in ([0-9]*). This would be main version like 37
            # a[2] => Stores the matched string in ([.0-9]*). This would be the subversion like 1.7
          done < /tmp/scrape)

fedora_ver=$(echo "$temp_ver" | head -1)
sub_ver=$(echo "$temp_ver" | tail -1)

iso="Fedora-Workstation-Live-x86_64-${fedora_ver}-${sub_ver}.iso"
url="https://download.fedoraproject.org/pub/fedora/linux/releases/${fedora_ver}/Workstation/x86_64/iso"
checksum_file="Fedora-Workstation-${fedora_ver}-${sub_ver}-x86_64-CHECKSUM"
checksum_url="https://getfedora.org/static/checksums/${fedora_ver}/iso"
gpg_file="fedora.gpg"
gpg_url="https://getfedora.org/static"
rem_space=""

chkRemSpace

if [ "$rem_space" -ge 0 ]
then
  downloadISO
  downloadChecksum
  downloadGPG
  chkAuth
  chkInt
else
  calcReqSpace "$rem_space"
fi

cleanup

exit 0