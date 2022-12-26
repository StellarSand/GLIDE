#!/bin/bash

source ./common_utils.sh

CentStreamVer=$(version CentOS_Stream)

ISO="CentOS-Stream-${CentStreamVer}-latest-x86_64-dvd1.iso"
URL="https://mirrors.centos.org/mirrorlist?path=/${CentStreamVer}-stream/BaseOS/x86_64/iso"
SHA_File="SHA256SUM"

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(DownloadDir)\n"
  curl -L -o "$(DownloadDir)"/"${ISO}" "${URL}/${ISO}&redirect=1&protocol=https"
  success_fail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(DownloadDir)\n"
  curl -L -o "$(DownloadDir)"/$SHA_File "${URL}"/${SHA_File}
  success_fail
}

downloadISO
downloadSHA
check_int

exit 0