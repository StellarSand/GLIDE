#!/usr/bin/env bash

source /usr/local/lib/GLIDE/common_utils.sh

# Checks disk free space after all files would be downloaded
chkRemSpace() {
  echo -e "\nChecking available disk space ..."
  echo -e "This may take a while ...\n"
  ISOSize=$(dnldFileSize "$URL"/"$ISO")
  SHASize=$(dnldFileSize "$URL"/"$SHA_File")
  GPGSize=$(dnldFileSize "$URL"/"$GPG_File")
  TotalDnldSize=$(awk -v ISOSize="$ISOSize" -v SHASize="$SHASize" -v GPGSize="$GPGSize" 'BEGIN {print ISOSize + SHASize + GPGSize}')
  RemSpace=$(($(diskFreeSpace)-"$TotalDnldSize"))
}

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$ISO" "$URL"/"$ISO"
  successFail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$SHA_File" "$URL"/"$SHA_File"
  successFail
}

# Download GPG file
downloadGPG() {
  echo -e "\nDownloading GPG file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$GPG_File" "$URL"/"$GPG_File"
  successFail
}

# Check authenticity of downloaded iso
chkAuth() {
  echo -e "\nAdding GPG keys ...\n"
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$Ubuntu_GKey"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpg --keyid-format long --verify "$GPG_File" "$SHA_File"
}

# Check integrity of downloaded ISO
chkInt() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha256sum -c "$SHA_File" 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

chkVer "https://ubuntu.com/download/desktop"

echo -e "\nSelect whether to download LTS or Non-LTS"
echo -e "1. LTS\n2. Non-LTS\n"
read -p "Enter 1 or 2: " lts

if [ "$lts" -eq 1 ]
then
  UbuntuVer=$(grep '<h2>Ubuntu' /tmp/scrape | #Returns 3 lines
              head -n 1 | #Keeps only the first line
              sed 's/.*Ubuntu //' | #Removes everything before ver no.
              sed 's/ LTS.*//') #Removes everything after version number
else
  UbuntuVer=$(grep '<h2>Ubuntu' /tmp/scrape | #Returns 3 lines
              head -n -1 | #Removes last line
              tail -n 1 | #Removes first line
              sed 's/.*Ubuntu //' | #Removes everything before ver no.
              sed 's/<.*//')
fi

ISO="ubuntu-${UbuntuVer}-desktop-amd64.iso"
URL="https://releases.ubuntu.com/${UbuntuVer}"
SHA_File="SHA256SUMS"
GPG_File="${SHA_File}.gpg"
Ubuntu_GKey=$(GKey Ubuntu)
RemSpace=""

chkRemSpace

if [ "$RemSpace" -ge 0 ]
then
  downloadISO
  downloadSHA
  downloadGPG
  chkAuth
  chkInt
else
  calcReqSpace "$RemSpace"
fi

cleanup

exit 0