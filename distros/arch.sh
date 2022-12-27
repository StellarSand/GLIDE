#!/bin/bash

source ./common_utils.sh

Arch_GKey=$(GKey Arch)

ISO=""
URL=""
SHA_File="sha256sums.txt"

# Check for latest version
chkVer() {
  echo -e "Checking for latest version ..."
  echo -e "This may take a while ...\n"
  curl -s "https://archlinux.org/download/" > /tmp/scrape

  ArchVer=$(while read -r;
            do
              sed -n '/https:\/\/geo.mirror.pkgbuild.com\/iso/,$p' | #Removes everything before this line
              sed -n '/title/q;p' | #Removes everything after "title" including this line
              sed 's/.*iso\///' | #Removes everything before ver no.
              sed 's/\/"//'; #Removes /" after version number
            done < /tmp/scrape)

  ISO="archlinux-$ArchVer-x86_64.iso"
  URL="https://mirror.rackspace.com/archlinux/iso/$ArchVer"
  Sig_File="${ISO}.sig"

}

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"${ISO}" "${URL}"/"${ISO}"
  successFail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/$SHA_File "${URL}"/${SHA_File}
  successFail
}

# Download Sig file
downloadSig() {
  echo -e "\nDownloading Sig file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"${Sig_File}" "${URL}"/"${Sig_File}"
  successFail
}

# Check authenticity of downloaded iso
chkAuth() {
  echo -e "\nAdding GPG keys ...\n"
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"${Arch_GKey}"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpg --keyid-format long --verify "${Sig_File}"

}

# Check integrity of downloaded ISO
chkInt() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha256sum -c ${SHA_File} 2>&1 | grep OK)" = "" ]
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