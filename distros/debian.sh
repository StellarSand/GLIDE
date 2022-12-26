#!/bin/bash

source ./common_utils.sh

DebianVer=$(version Debian)
Debian_GKey=$(GKey Debian)

ISO="debian-${DebianVer}-amd64-DVD-1.iso"
URL="https://debian-cd.debian.net/debian-cd/${DebianVer}/amd64/iso-dvd"
SHA_File="SHA512SUMS"
Sig_File="SHA512SUMS.sign"

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(DownloadDir)\n"
  curl -L -o "$(DownloadDir)"/"${ISO}" "${URL}"/"${ISO}"
  success_fail
}

# Download Sig file
downloadSig() {
  echo -e "\nDownloading Sig file to $(DownloadDir)\n"
  curl -L -o "$(DownloadDir)"/"${Sig_File}" "${URL}"/"${Sig_File}"
  success_fail
}

# Check authenticity of downloaded iso
chk_auth() {
  echo -e "\nAdding GPG keys ...\n"
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$Debian_GKey"
  success_fail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  if [ ! "$(gpg --keyid-format long --verify "$(DownloadDir)"/"${Sig_File}" "$(DownloadDir)"/$SHA_File | grep -Fq "Good signature")" = "" ]
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
  if [ ! "$(sha512sum -c "$(DownloadDir)"/$SHA_File 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

downloadISO
downloadSig
chk_auth
chk_int

exit 0