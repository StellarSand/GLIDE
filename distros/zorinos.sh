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
  iso_size=$(dnldFileSize "https://mirrors.edge.kernel.org/zorinos-isos/$zorin_ver/$iso")
  rem_space=$(awk -v diskFreeSpace="$(diskFreeSpace)" -v iso_size="$iso_size" 'BEGIN {print (diskFreeSpace - iso_size)}')
}

# Download iso
downloadISO() {
  echo -e "Downloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$iso" "$url"/"$iso"
  successFail
}

# Check integrity of downloaded iso
chkInt() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ "$(sha256sum "$iso" | sed "s/  $iso//")" == "$sha" ]
    then
      echo -e "Success\n"
    else
      echo -e "Failed\n"
      echo -e "The ISO file has been modified or incorrectly downloaded.\n"
    fi
}

echo -e "\nSelect an edition to download"
echo -e "1. Core\n2. Lite\n"
read -p "Enter 1 or 2: " editn

if [ "$editn" -eq 2 ]
then
  edition="lite"
else
  edition="core"
fi

chkVer "https://zorin.com/os/download/"

zorin_ver=$(while read -r
           do
             awk 'match($0, /os\/download\/([0-9]*)/, a){print a[1]}' | 
             head -1
            done < /tmp/scrape)

curl -s "https://zorin.com/os/download/${zorin_ver}/${edition}/" > /tmp/scrape
iso=$(while read -r
      do
        awk 'match($0, /zorinos-isos\/'"$zorin_ver"'\/([A-z0-9.-]*)/, a){print a[1]}' | 
        head -1
      done < /tmp/scrape)
      # This is done because iso doesn't have
      # consistent naming like 16.0, 16.2
      # instead, names keep changing like 16, 16.2, 16.2-r1 etc etc

curl -s "https://help.zorin.com/docs/getting-started/check-the-integrity-of-your-copy-of-zorin-os/" > /tmp/scrape
sha=$(while read -r
      do
        awk 'match($0, /'"${edition^}"' 64-bit:<\/strong> <code>([a-z0-9]*)</, a){print a[1]}'
        # ${edition^} => converts core to Core
      done < /tmp/scrape)

url="https://free.download.zorinos.com/$zorin_ver"
rem_space=""

chkRemSpace

if [ "$rem_space" -ge 0 ]
then
  downloadISO
  chkInt
else
  calcReqSpace "$rem_space"
fi

cleanup

exit 0