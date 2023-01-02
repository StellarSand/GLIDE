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
}

# Download ISO
downloadISO() {
  echo -e "Downloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$ISO" "$URL"/"$ISO"
  successFail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$SHA_File" "${URL}"/"$SHA_File"
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
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$Arch_GKey"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpg --keyid-format long --verify "$Sig_File"

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

chkVer "https://archlinux.org/download/"

ArchVer=$(while read -r
          do
            sed -n '/https:\/\/geo.mirror.pkgbuild.com\/iso/,$p' | #Removes everything before this line
            sed -n '/title/q;p' | #Removes everything after "title" including this line
            sed 's/.*iso\///' | #Removes everything before ver no.
            sed 's/\/"//'; #Removes /" after version number
          done < /tmp/scrape)

ISO="archlinux-$ArchVer-x86_64.iso"
URL="https://mirror.rackspace.com/archlinux/iso/$ArchVer"
Sig_File="${ISO}.sig"
SHA_File="sha256sums.txt"
Arch_GKey=$(GKey Arch)
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