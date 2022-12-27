#!/bin/bash

source ./common_utils.sh

Debian_GKey=$(GKey Debian)

ISO=""
URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd"
SHA_File="SHA512SUMS"
Sig_File="${SHA_File}.sign"

# Check for latest version
chkVer() {
  echo -e "Checking for latest version ..."
  echo -e "This may take a while ...\n"
  curl -s "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/" > /tmp/scrape

  DebianVer=$(while read -r;
              do
                sed -n '/<a href="debian-/,$p' | #Removes everything before this line
                sed -n '/indexbreakrow/q;p' | #Removes everything after "indexbreakrow" including this line
                sed 's/.*debian-//' | #Removes everything before version number
                sed 's/-.*//'; #Removes everything after version number
              done < /tmp/scrape)

  ISO="debian-${DebianVer}-amd64-DVD-1.iso"
}

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"${ISO}" "${URL}"/"${ISO}"
  successFail
}

# Download Sig file
downloadSig() {
  echo -e "\nDownloading Sig file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"${Sig_File}" "${URL}"/"${Sig_File}"
  successFail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/$SHA_File "${URL}"/${SHA_File}
  successFail
}

# Check authenticity of downloaded iso
chkAuth() {
  echo -e "\nAdding GPG keys ...\n"
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$Debian_GKey"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpg --keyid-format long --verify ${Sig_File} ${SHA_File}
}

# Check integrity of downloaded ISO
chkInt() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha512sum -c ${SHA_File} 2>&1 | grep OK)" = "" ]
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
downloadSig
chkAuth
chkInt

cleanup

exit 0