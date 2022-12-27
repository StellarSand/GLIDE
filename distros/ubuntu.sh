#!/bin/bash

source ./common_utils.sh

Ubuntu_GKey=$(GKey Ubuntu)

ISO=""
URL=""
SHA_File="SHA256SUMS"
SHA_GPG_File="${SHA_File}.gpg"

# Check for latest version
chkVer() {
  echo -e "Checking for latest version ..."
  echo -e "This may take a while ...\n"
  curl -s "https://ubuntu.com/download/desktop" > /tmp/scrape

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

}

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"${ISO}" "${URL}"/"${ISO}"
  successFail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/${SHA_File} "${URL}"/${SHA_File}
  successFail
}

# Download GPG file
downloadGPG() {
  echo -e "\nDownloading GPG file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"${SHA_GPG_File}" "${URL}"/"${SHA_GPG_File}"
  successFail
}

# Check authenticity of downloaded iso
chkAuth() {
  echo -e "\nAdding GPG keys ...\n"
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"${Ubuntu_GKey}"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpg --keyid-format long --verify ${SHA_GPG_File} ${SHA_File}
}

# Check integrity of downloaded ISO
chkInt() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha256sum -c ${SHA_File} 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

chkVer
downloadISO
downloadSHA
downloadGPG
chkAuth
chkInt

cleanup

exit 0