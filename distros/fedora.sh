#!/bin/bash

source ./common_utils.sh

FedoraVer=$(version Fedora)

ISO="Fedora-Workstation-Live-x86_64-${FedoraVer}-1.2.iso"
URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${FedoraVer}/Workstation/x86_64/iso"
Checksum="Fedora-Workstation-${FedoraVer}-1.2-x86_64-Checksum"
Checksum_URL="https://getfedora.org/static/checksums/${FedoraVer}/iso"
GPG_File="fedora.gpg"
GPG_URL="https://getfedora.org/static/${GPG_File}"

# Download ISO
downloadISO() {
  echo -e "\nDownloading ISO to $(DownloadDir)\n"
  curl -L -o "$(DownloadDir)"/"${ISO}" "${URL}"/"${ISO}"
  success_fail
}

# Download Checksum
downloadChecksum() {
  echo -e "\nDownloading checksum to $(DownloadDir)\n"
  curl -L -o "$(DownloadDir)"/"${Checksum}" "${Checksum_URL}"/"${Checksum}"
  success_fail
}

chk_auth() {
  echo -e "\nImporting GPG keys ...\n"
  curl -L -o "$(DownloadDir)"/${GPG_File} ${GPG_URL}
  success_fail

  echo -e "\nChecking authenticity of the downloaded iso ...\n"
  if [ ! "$(gpgv --keyring "$(DownloadDir)"/fedora.gpg "$(DownloadDir)"/*-CHECKSUM | grep -Fq "Good signature")" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "ISO downloaded is not authentic.\n"
  fi
}

chk_int() {
  echo -e "\nChecking integrity of the downloaded iso ...\n"
  if [ ! "$(sha256sum -c "$(DownloadDir)"/*-Checksum 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

downloadISO
downloadChecksum
chk_auth
chk_int

exit 0