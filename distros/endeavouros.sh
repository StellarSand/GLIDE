#!/bin/bash

source ./common_utils.sh

Endeavour_GKey=$(GKey Endeavour)

ISO=""
URL="https://github.com/endeavouros-team/ISO/releases/download/1-EndeavourOS-ISO-releases-archive"

# Check for latest version
chkVer() {
  echo -e "Checking for latest version ..."
  echo -e "This may take a while ...\n"
  curl -s "https://endeavouros.com/latest-release/" > /tmp/scrape

  EndeavourVer=$(while read -r;
                 do
                  sed -n '/wp-block-table/,$p' | #Removes everything before this line
                  sed -n '/<\/div>/q;p' | #Removes everything after "</div>" including this line
                  sed 's/.*Alpix//' | #Removes everything before & including "Alpix"
                  sed 's/Download.*//' | #Removes everything after & including "Download"
                  sed 's/.*EndeavourOS_//' | #Removes everything before & including "EndeavourOS_"
                  sed 's/.iso.*//'; #Removes everything after & including ".iso"
                 done < /tmp/scrape)

  ISO="EndeavourOS_${EndeavourVer}.iso"
  SHA_File="${ISO}.sha512sum"
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
  curl -L -o "$(downloadDir)"/"${SHA_File}" ${URL}/"${SHA_File}"
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
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$Endeavour_GKey"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  if [ ! "$(gpg --keyid-format long --verify "$(downloadDir)"/"${Sig_File}" "$(downloadDir)"/"${SHA_File}" | grep -Fq "Good signature")" = "" ]
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
  if [ ! "$(sha512sum -c "$(downloadDir)"/"${SHA_File}" 2>&1 | grep OK)" = "" ]
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