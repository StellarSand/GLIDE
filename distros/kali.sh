#!/bin/bash

source ./common_utils.sh

Kali_GKey=$(GKey Kali)

ISO=""
URL=""
SHA_File="SHA256SUMS"
SHA_GPG_File="${SHA_File}.gpg"

# Check for latest version
chkVer() {
  echo -e "Checking for latest version ..."
  echo -e "This may take a while ...\n"
  curl -s "https://www.kali.org/get-kali/" > /tmp/scrape

  KaliVer=$(while read -r;
            do
              sed -n '/Changelog/,$p' | #Removes everything before this line
              sed -n '/32-bit/q;p' | #Removes everything after "32-bit" including this line
              sed 's/.*header-link>Kali Linux //' | #Removes everything before ver no.
              sed 's/ Changelog.*//'; #Removes everything after version number
            done < /tmp/scrape)

  ISO="kali-linux-$KaliVer-installer-amd64.iso"
  URL="https://cdimage.kali.org/kali-$KaliVer"

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
  curl -L -o "$(downloadDir)"/${SHA_File} "${URL}"/${SHA_File}
  successFail
}

# Download GPG file
downloadGPG() {
  echo -e "\nDownloading GPG file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"${SHA_GPG_File}" "${URL}"/"${SHA_GPG_File}"
  successFail
}

# Check authenticity of downloaded iso
chk_auth() {
  echo -e "\nAdding GPG keys ...\n"
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"${Kali_GKey}"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  if [ ! "$(gpg --keyid-format long --verify "$(downloadDir)"/"${SHA_GPG_File}" "$(downloadDir)"/${SHA_File} | grep -Fq "Good signature")" = "" ]
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
  if [ ! "$(sha256sum -c "$(downloadDir)"/${SHA_File} 2>&1 | grep OK)" = "" ]
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
downloadGPG
chk_auth
chk_int

cleanup

exit 0