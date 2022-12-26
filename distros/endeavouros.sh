#!/bin/bash

source ./common_utils.sh

EndeavourVer=$(version Endeavour)
Endeavour_GKey=$(GKey Endeavour)

ISO="EndeavourOS_${EndeavourVer}.iso"
URL="https://github.com/endeavouros-team/ISO/releases/download/1-EndeavourOS-ISO-releases-archive"
SHA_File="${ISO}.sha512sum"
Sig_File="${ISO}.sig"

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(DownloadDir)\n"
  curl -L -o "$(DownloadDir)"/"${ISO}" "${URL}"/"${ISO}"
  success_fail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(DownloadDir)\n"
  curl -L -o "$(DownloadDir)"/"${SHA_File}" ${URL}/"${SHA_File}"
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
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$Endeavour_GKey"
  success_fail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  if [ ! "$(gpg --keyid-format long --verify "$(DownloadDir)"/"${Sig_File}" "$(DownloadDir)"/"${SHA_File}" | grep -Fq "Good signature")" = "" ]
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
  if [ ! "$(sha512sum -c "$(DownloadDir)"/"${SHA_File}" 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

downloadISO
downloadSHA
downloadSig
chk_auth
chk_int

exit 0