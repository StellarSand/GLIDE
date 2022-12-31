#!/usr/bin/env bash

source /usr/local/lib/GLIDE/common_utils.sh

GPG_File="fedora.gpg"
GPG_URL="https://getfedora.org/static/${GPG_File}"

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"${ISO}" "${URL}"/"${ISO}"
  successFail
}

# Download Checksum
downloadChecksum() {
  echo -e "\nDownloading checksum to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"${Checksum}" "${Checksum_URL}"/"${Checksum}"
  successFail
}

# Download GPG file
downloadGPG() {
  echo -e "\nDownloading GPG file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/${GPG_File} ${GPG_URL}
  successFail
}

chkAuth() {
  echo -e "\nChecking authenticity of the downloaded iso ...\n"
  cd "$(downloadDir)" || exit
  gpgv --keyring ./fedora.gpg *-CHECKSUM
}

chkInt() {
  echo -e "\nChecking integrity of the downloaded iso ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha256sum -c *-CHECKSUM 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

chkVer "https://alt.fedoraproject.org/"

FedoraVer=$(while read -r
           do
             sed -n '/Fedora-Everything/,$p' | #Removes everything before "Fedora-Everything" line
             sed -n '/ <\//q;p' | #Removes everything after "</"and including this line
             sed 's/.*netinst-x86_64-//' | #Removes everything before and including "netinst-x86_64-"
             sed 's/-.*//'; #Only keeps main version like "37"
           done < /tmp/scrape)

SubVer=$(while read -r
         do
           sed -n '/Fedora-Everything/,$p' | #Removes everything before "Fedora-Everything" line
           sed -n '/ <\//q;p' | #Removes everything after "</"and including this line
           sed "s/.*x86_64-${FedoraVer}-//" | #Removes everything before "x86_64_37-"
           sed 's/.iso".*//'; #Only keeps sub version like "1.7"
         done < /tmp/scrape)

ISO="Fedora-Workstation-Live-x86_64-${FedoraVer}-${SubVer}.iso"
URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${FedoraVer}/Workstation/x86_64/iso"
Checksum="Fedora-Workstation-${FedoraVer}-${SubVer}-x86_64-CHECKSUM"
Checksum_URL="https://getfedora.org/static/checksums/${FedoraVer}/iso"

downloadISO
downloadChecksum
downloadGPG
chkAuth
chkInt

cleanup

exit 0