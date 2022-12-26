#!/bin/bash

source ./common_utils.sh

UbuntuVer=""
Ubuntu_GKey=$(GKey Ubuntu)

ISO=""
URL=""
SHA_File="SHA256SUMS"
SHA_GPG_File="${SHA_File}.gpg"

UbVer() {
  echo -e "\nSelect whether to download LTS or Non-LTS"
  echo -e "1. LTS\n2. Non-LTS\n"
  read -p "Enter 1 or 2: " yesno

  if [ "$yesno" -eq 1 ]
  then
    UbuntuVer=$(version Ubuntu_LTS)
  else
    UbuntuVer=$(version Ubuntu_Non_LTS)
  fi

  ISO="ubuntu-${UbuntuVer}-desktop-amd64.iso"
  URL="https://releases.ubuntu.com/${UbuntuVer}"
}

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(DownloadDir)\n"
  curl -L -o "$(DownloadDir)"/"${ISO}" "${URL}"/"${ISO}"
  success_fail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(DownloadDir)\n"
  curl -L -o "$(DownloadDir)"/${SHA_File} "${URL}"/${SHA_File}
  success_fail
}

# Download GPG file
downloadGPG() {
  echo -e "\nDownloading GPG file to $(DownloadDir)\n"
  curl -L -o "$(DownloadDir)"/"${SHA_GPG_File}" "${URL}"/"${SHA_GPG_File}"
  success_fail
}

# Check authenticity of downloaded iso
chk_auth() {
  echo -e "\nAdding GPG keys ...\n"
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"${Ubuntu_GKey}"
  success_fail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  if [ ! "$(gpg --keyid-format long --verify "$(DownloadDir)"/"${SHA_GPG_File}" "$(DownloadDir)"/${SHA_File} | grep -Fq "Good signature")" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "ISO downloaded is not authentic.\n"
  fi
}

# Check integrity of downloaded ISO
chk_int() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  if [ ! "$(sha256sum -c "$(DownloadDir)"/${SHA_File} 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

UbVer
downloadISO
downloadSHA
downloadGPG
chk_auth
chk_int

exit 0