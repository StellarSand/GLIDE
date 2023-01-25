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
  echo $rem_space
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
  curl -L -o "$(downloadDir)"/"$sha_file" "$url"/"$sha_file"
  successFail
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
  gpg --keyid-format long --keyserver hkps://keyserver.ubuntu.com --recv-key 0x"$debian_gkey"
  successFail

  echo -e "\nChecking authenticity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  gpg --keyid-format long --verify "$sig_file" "$sha_file"
}

# Check integrity of downloaded iso
chkInt() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ ! "$(sha512sum -c "$sha_file" 2>&1 | grep OK)" = "" ]
  then
    echo -e "Success\n"
  else
    echo -e "Failed\n"
    echo -e "The ISO file has been modified or incorrectly downloaded.\n"
  fi
}

chkVer "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/"

debian_ver=$(while read -r
            do
              awk 'match($0, /<a href="debian-([.0-9]*)/, a){print a[1]}'
              # $0 => current line
              # /<a href="debian- => search for <a href="debian-
              # [.0-9] => matches anything that is a dot or digit.
              # * => zero or more times
              # a => store the matched substrings in an array 'a'
              # a[1] => The array index corresponds to matched string in groups enclosed in (). Here it's ([.0-9]*)
            done < /tmp/scrape)

iso="debian-${debian_ver}-amd64-DVD-1.iso"
url="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd"
sha_file="SHA512SUMS"
sig_file="${sha_file}.sign"
debian_gkey=$(GKey Debian)
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