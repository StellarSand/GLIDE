#!/usr/bin/env bash

source /usr/local/lib/GLIDE/common_utils.sh

# Checks disk free space after all files would be downloaded
chkRemSpace() {
  echo "Checking available disk space ..."
  echo -e "This may take a while ...\n"
  ISOSize=$(dnldFileSize "https://mirrors.edge.kernel.org/zorinos-isos/$ZorinVer/$ISO")
  RemSpace=$(awk -v diskFreeSpace="$(diskFreeSpace)" -v ISOSize="$ISOSize" 'BEGIN {print (diskFreeSpace - ISOSize)}')
}

# Download ISO
downloadISO() {
  echo -e "Downloading ISO to $(downloadDir)\n"
  curl -L -o "$(downloadDir)"/"$ISO" "$URL"/"$ISO"
  successFail
}

# Check integrity of downloaded ISO
chkInt() {
  echo -e "\nChecking integrity of the downloaded ISO ...\n"
  cd "$(downloadDir)" || exit
  if [ "$(sha256sum "$ISO" | sed "s/  $ISO//")" == "$SHA" ]
    then
      echo -e "Success\n"
    else
      echo -e "Failed\n"
      echo -e "The ISO file has been modified or incorrectly downloaded.\n"
    fi
}

echo -e "\nSelect an Edition to download"
echo -e "1. Core\n2. Lite\n"
read -p "Enter 1 or 2: " editn

if [ "$editn" -eq 2 ]
then
  Edition="Lite"
else
  Edition="Core"
fi

chkVer "https://zorin.com/os/download/"

ZorinVer=$(while read -r
           do
             sed -n '/Core<\/h2>/,$p' | # Removes everything before this line
             sed -n '/<p/q;p' | # Removes everything after "div" including this line
             sed 's/.*.*Zorin OS //' | # Removes everything before ver no.
             sed 's/..<.*//' # Only keeps main ver no. like "16"
            done < /tmp/scrape)

SubVer=$(while read -r
         do
           sed -n '/Core<\/h2>/,$p' | # Removes everything before this line
           sed -n '/<p/q;p' | # Removes everything after "div" including this line
           sed "s/.*.*Zorin OS ${ZorinVer}.//" | # Removes everything before sub ver no.
           sed 's/<\/span>.*//' # Only keeps sub ver like "2"
         done < /tmp/scrape)

curl -s "https://zorin.com/os/download/${ZorinVer}/${Edition}/" > /tmp/scrape
ISO=$(while read -r
      do
        sed -n '/mirrors.edge/,$p' |
        sed -n '/<\/ul>/q;p' |
        sed "s/.*zorinos-isos\/${ZorinVer}\///" |
        sed 's/".*//'
      done < /tmp/scrape) # This is done because iso don't have
                          # consistent naming like 16.0, 16.2
                          # instead, names keep changing like 16, 16.2, 16.2-r1 etc etc

curl -s "https://help.zorin.com/docs/getting-started/check-the-integrity-of-your-copy-of-zorin-os/" > /tmp/scrape
SHA=$(while read -r
      do
        sed -n "/Zorin OS ${ZorinVer}.${SubVer} ${Edition} 64-bit/,\$p" |
        sed -n '/twitter.com/q;p' |
        sed "s/.*${ZorinVer}.${SubVer} ${Edition} 64-bit:<\/strong> <code>//" |
        sed 's/<\/code>.*//'
      done < /tmp/scrape)

URL="https://free.download.zorinos.com/${ZorinVer}"
RemSpace=""

chkRemSpace

if [ "$RemSpace" -ge 0 ]
then
  downloadISO
  chkInt
else
  calcReqSpace "$RemSpace"
fi

cleanup

exit 0