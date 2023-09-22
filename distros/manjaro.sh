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

# Select desktop environment
selDE() {
  echo -e "\nSelect a desktop environment:"
  echo -e "1. KDE Plasma\n2. XFCE\n3. GNOME"
  read -p "Enter 1, 2 or 3: " de

  if [ "$de" -eq 1 ]
  then
    de="kde"
  elif [ "$de" -eq 2 ]
  then
    de="xfce"
  else
    de="gnome"
  fi
}

selEdition(){
  echo -e "\nSelect minimal or full iso:"
  echo -e "1. Minimal\n2. Full"
  read -p "Enter 1 or 2: " min_full

  if [ "$min_full" -eq 1 ]
  then
  is_minimal=true
  fi
}

# Checks disk free space after all files would be downloaded
chkRemSpace() {
  echo -e "\nChecking available disk space ..."
  echo -e "This may take a while ...\n"
  iso_size=$(dnldFileSize "$url"/"$iso")
  sha_size=$(dnldFileSize "$url"/"$sha_file")
  sig_size=$(dnldFileSize "$url"/"$sig_file")
  total_dnld_size=$(awk -v iso_size="$iso_size" -v sha_size="$sha_size" -v sig_size="$sig_size" 'BEGIN {print iso_size + sha_size + sig_size}')
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

# Download Sig file
downloadSig() {
  echo -e "\nDownloading Sig file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$sig_file" "$url"/"$sig_file"
  successFail
}

# Check authenticity of downloaded iso
chkAuth() {
  echo -e "\nAdding GPG keys ...\n"
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$manjaro_gkey"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpg --keyid-format long --verify "$sig_file"
}

# Check integrity of downloaded iso
chkInt() {
  echo -e "Checking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha1sum -c "$sha_file" 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

de=""
is_minimal=false
manjaro_gkey=$(GKey Manjaro)
rem_space=""

selDE
selEdition

chkVer "https://manjaro.org/download/"

temp_ver=$(while read -r
          do
            awk 'match($0, /manjaro-kde-([.0-9]*)-minimal-([a-z0-9-]*).iso/, a){print a[1] "\n" a[2]}'
            # $0 => current line
            # /x86_64- => search for x86_64-
            # [a-z0-9-] => matches anything that is a letter, digit or -
            # * => zero or more times
            # a => store the matched substrings in an array 'a'
            # a[1] => Stores the matched string in ([.0-9]*). This would be main version like 22.0
            # a[2] => Stores the matched string in ([a-z0-9-]*). This would be the subversion like 221224-linux61
          done < /tmp/scrape)

manjaro_ver=$(echo "$temp_ver" | head -1)
sub_ver=$(echo "$temp_ver" | tail -1)

if $is_minimal
then
  iso="manjaro-${de}-${manjaro_ver}-minimal-${sub_ver}.iso"
else
  iso="manjaro-${de}-${manjaro_ver}-${sub_ver}.iso"
fi

url="https://download.manjaro.org/${de}/${manjaro_ver}"
sha_file="${iso}.sha1"
sig_file="${iso}.sig"

chkRemSpace

if [ "$rem_space" -ge 0 ]
then
  downloadISO
  downloadSHA
  downloadSig
  chkAuth
  chkInt
else
  calcReqSpace "$rem_space"
fi

cleanup

exit 0