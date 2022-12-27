#!/bin/bash

source ./common_utils.sh

ISO=""
URL=""
SHA_File="SHA256SUM"

# Check for latest version
chkVer() {
  echo -e "Checking for latest version ..."
  echo -e "This may take a while ...\n"
  curl -s "https://www.centos.org/centos-stream/" > /tmp/scrape

  CentStreamVer=$(while read -r;
                  do
                  sed -n '/https:\/\/mirrors.centos.org/,$p' | #Removes everything before this line
                  sed -n '/http:\/\/mirror.stream/q;p' | #Removes everything after & including this line
                  sed 's/.*=\///' | #Removes everything before ver no.
                  sed 's/-.*//'; #Removes everything after version number
            done < /tmp/scrape)

  ISO="CentOS-Stream-${CentStreamVer}-latest-x86_64-dvd1.iso"
  URL="https://mirrors.centos.org/mirrorlist?path=/${CentStreamVer}-stream/BaseOS/x86_64/iso"

}

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"${ISO}" "${URL}/${ISO}&redirect=1&protocol=https"
  successFail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/$SHA_File "${URL}"/${SHA_File}
  successFail
}

chkVer
downloadISO
downloadSHA

cleanup

exit 0