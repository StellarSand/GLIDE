#!/usr/bin/env bash

source /usr/local/lib/GLIDE/common_utils.sh

# Checks disk free space after all files would be downloaded
chkRemSpace() {
  echo "Checking available disk space ..."
  echo -e "This may take a while ...\n"
  ISOSize=$(dnldFileSize "$URL"/"$ISO")
  SHASize=$(dnldFileSize "$URL"/"$SHA_File")
  SigSize=$(dnldFileSize "$URL"/"$Sig_File")
  TotalDnldSize=$(awk -v ISOSize="$ISOSize" -v SHASize="$SHASize" -v SigSize="$SigSize" 'BEGIN {print ISOSize + SHASize + SigSize}')
  RemSpace=$(($(diskFreeSpace)-"$TotalDnldSize"))
  echo $RemSpace
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

# Download Sig file
downloadSig() {
  echo -e "\nDownloading Sig file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$Sig_File" "$URL"/"$Sig_File"
  successFail
}

# Check authenticity of downloaded iso
chkAuth() {
  echo -e "\nAdding GPG keys ...\n"
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$Debian_GKey"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpg --keyid-format long --verify "$Sig_File" "$SHA_File"
}

# Check integrity of downloaded ISO
chkInt() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha512sum -c "$SHA_File" 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

chkVer "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/"

DebianVer=$(while read -r
            do
              sed -n '/<a href="debian-/,$p' | #Removes everything before this line
              sed -n '/indexbreakrow/q;p' | #Removes everything after "indexbreakrow" including this line
              sed 's/.*debian-//' | #Removes everything before version number
              sed 's/-.*//' #Removes everything after version number
            done < /tmp/scrape)

ISO="debian-${DebianVer}-amd64-DVD-1.iso"
URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd"
SHA_File="SHA512SUMS"
Sig_File="${SHA_File}.sign"
Debian_GKey=$(GKey Debian)
RemSpace=""

chkRemSpace

if [ "$RemSpace" -ge 0 ]
then
  downloadISO
  downloadSHA
  downloadSig
  chkAuth
  chkInt
else
  calcReqSpace "$RemSpace"
fi

cleanup

exit 0