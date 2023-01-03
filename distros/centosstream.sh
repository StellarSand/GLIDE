#!/usr/bin/env bash

source /usr/local/lib/GLIDE/common_utils.sh

# Checks disk free space after all files would be downloaded
chkRemSpace() {
  echo "Checking available disk space ..."
  echo -e "This may take a while ...\n"
  ISOSize=$(dnldFileSize "$URL"/"$ISO")
  SHASize=$(dnldFileSize "$URL"/"$SHA_File")
  TotalDnldSize=$(awk -v ISOSize="$ISOSize" -v SHASize="$SHASize" 'BEGIN {print (ISOSize + SHASize) * 1024**2}')
  RemSpace=$(($(diskFreeSpace)-"$TotalDnldSize"))
}

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$ISO" "$URL/${ISO}&redirect=1&protocol=https"
  successFail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$SHA_File" "$URL"/"$SHA_File"
  successFail
}

# Check authenticity of downloaded iso
chkAuth() {
  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ "$(sha256sum "$ISO")" == "$(cat "$SHA_File")" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "ISO downloaded is not authentic.\n"
  fi
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

chkVer "https://www.centos.org/centos-stream/"

CentStreamVer=$(while read -r
                do
                  sed -n '/https:\/\/mirrors.centos.org/,$p' | #Removes everything before this line
                  sed -n '/http:\/\/mirror.stream/q;p' | #Removes everything after & including this line
                  sed 's/.*=\///' | #Removes everything before ver no.
                  sed 's/-.*//' #Removes everything after version number
                done < /tmp/scrape)

ISO="CentOS-Stream-${CentStreamVer}-latest-x86_64-dvd1.iso"
URL="https://mirrors.centos.org/mirrorlist?path=/${CentStreamVer}-stream/BaseOS/x86_64/iso"
SHA_File="${ISO}.SHA256SUM"
RemSpace=""

chkRemSpace

if [ "$RemSpace" -ge 0 ]
then
  downloadISO
  downloadSHA
  chkAuth
  chkInt
else
  calcReqSpace "$RemSpace"
fi

cleanup

exit 0