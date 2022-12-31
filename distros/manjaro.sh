#!/usr/bin/env bash

source /usr/local/lib/GLIDE/common_utils.sh

Manjaro_GKey=$(GKey Manjaro)

ISO=""
URL=""
SHA_File=""
Sig_File=""

# Select desktop environment
selDE() {
  echo -e "\nSelect a desktop environment:"
  echo -e "1. KDE Plasma\n2. XFCE\n3. GNOME"
  read -p "Enter 1, 2 or 3: " DE

  if [ "$DE" -eq 1 ]
  then
    DE="kde"
  elif [ "$DE" -eq 2 ]
  then
    DE="xfce"
  else
    DE="gnome"
  fi

  echo -e "\nSelect minimal or full ISO:"
  echo -e "1. Minimal\n2. Full"
  read -p "Enter 1 or 2: " min_full

  if [ "$min_full" -eq 1 ]
  then
    ISO="manjaro-${DE}-${ManjaroVer}-minimal-${SubVer}.iso"
  else
    ISO="manjaro-${DE}-${ManjaroVer}-${SubVer}.iso"
  fi

  URL="https://download.manjaro.org/${DE}/${ManjaroVer}"
  SHA_File="${ISO}.sha1"
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
  curl -L -o "$(downloadDir)"/"${SHA_File}" "${URL}"/"${SHA_File}"
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
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"${Manjaro_GKey}"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpg --keyid-format long --verify "${Sig_File}"
}

# Check integrity of downloaded ISO
chkInt() {
  echo -e "Checking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha1sum -c "${SHA_File}" 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

chkVer "https://manjaro.org/download/"

ManjaroVer=$(while read -r
             do
               sed -n '/<a id="btn-ft/,$p' | #Removes everything before "<a id="btn-ft" line
               sed -n '/<i class/q;p' | #Removes everything after & including "<i class" line
               sed 's/.*manjaro-kde-//' | #Removes everything before & including "manjaro-kde-"
               sed 's/-.*//'; #Removes everything after main version like 22.0
             done < /tmp/scrape)

SubVer=$(while read -r
         do
           sed -n '/<a id="btn-ft/,$p' | #Removes everything before "<a id="btn-ft" line
           sed -n '/<i class/q;p' | #Removes everything after & including "<i class" line
           sed "s/.*${ManjaroVer}-//" | #Removes everything before sub version
           sed 's/.iso.*//'; #Removes everything after ".iso"
         done < /tmp/scrape)

selDE
downloadISO
downloadSHA
downloadSig
chkAuth
chkInt

cleanup

exit 0