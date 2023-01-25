#!/usr/bin/env bash

source /usr/local/lib/GLIDE/common_utils.sh

# Checks disk free space after all files would be downloaded
chkRemSpace() {
  echo "Checking available disk space ..."
  echo -e "This may take a while ...\n"
  iso_size=$(dnldFileSize "$url"/"$iso")
  sha_size=$(dnldFileSize "$url"/"$sha_file")
  sig_size=$(dnldFileSize "$url"/"$sig_file")
  total_dnld_size=$(awk -v iso_size="$iso_size" -v sha_size="$sha_size" -v sig_size="$sig_size" 'BEGIN {print iso_size + sha_size + sig_size}')
  rem_space=$(($(diskFreeSpace)-"$total_dnld_size"))
}

# Download iso
downloadISO() {
  echo -e "\nDownloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$iso" "$url"/"$iso"
  successFail
}

# Download SHA File
downloadSHA() {
  echo -e "\nDownloading SHA file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$sha_File" "$url"/"$sha_File"
f successFail
}

# Download Sig file
downloadSig() {
  echo -e "\nDownloading Sig file to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$sig_file" "$url"/"$sig_file"
  successFail
}

# Check authenticity of downloaded iso
chkAuth() {
  echo -e "\nAdding GPG keys ...\n"
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$endeavour_gkey"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpg --keyid-format long --verify "$sig_file"
}

# Check integrity of downloaded iso
chkInt() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha512sum -c "$sha_File" 2>&1 | grep OK)" = "" ]
f then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

chkVer "https://endeavouros.com/latest-release/"

endeavour_ver=$(while read -r
               do
                 awk 'match($0, /EndeavourOS_([A-z0-9_]*)/, a){print a[1]}' | 
                 # $0 => current line
                 # /EndeavourOS_ => search for EndeavourOS_
                 # [A-z0-9_] => matches anything that is a letter(upper/lower case), digit or underscore.
                 # * => zero or more times
                 # a => store the matched substrings in an array 'a'
                 # a[1] => The array index corresponds to matched string in groups enclosed in (). Here it's ([A-z0-9_]*)
                 head -1 # Returns first line of awk output
               done < /tmp/scrape)

iso="EndeavourOS_${endeavour_ver}.iso"
url="https://github.com/endeavouros-team/iso/releases/download/1-EndeavourOS-iso-releases-archive"
sha_file="${iso}.sha512sum"
sig_file="${iso}.sig"
endeavour_gkey=$(GKey Endeavour)
rem_space=""

chkRemSpace

if [ "$rem_space" -ge 0 ]
then
  downloadISO
  downloadSHA
  downloadSig
  chkAuth
  chkInt
else
  calcReqSpace "$rem_space"
fi

cleanup

exit 0