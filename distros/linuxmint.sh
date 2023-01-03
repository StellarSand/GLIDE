#!/usr/bin/env bash

source /usr/local/lib/GLIDE/common_utils.sh

# Checks disk free space after all files would be downloaded
chkRemSpace() {
  echo "Checking available disk space ..."
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
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$LMint_GKey"
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

chkVer "https://linuxmint.com/download.php"

LMintVer=$(while read -r
          do
            sed -n '/Download/,$p' | #Removes everything before this line
            sed -n '/<meta/q;p' | #Removes everything after "<meta" including this line
            sed 's/.*Mint //' | #Removes everything before ver no.
            sed 's/  -.*//' #Removes everything after version number
          done < /tmp/scrape)

ISO="linuxmint-${LMintVer}-cinnamon-64bit.iso"
URL="https://mirrors.layeronline.com/linuxmint/stable/${LMintVer}"
SHA_File="sha256sum.txt"
GPG_File="${SHA_File}.gpg"
LMint_GKey=$(GKey LinuxMint)
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
