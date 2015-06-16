#!/bin/bash

#find the right SAS ID for the drive letter in question
drive=`sg_inq $1 -p 0x83 | grep Vendor | sed -n 2p | grep -o ....$`
echo $drive

#search all of the JBODS (exclude all ata SG devices) for the drive in question
array=`for i in $(sg_map -i | awk '!/ATA/ {print $1}'); do sg_ses -p 0xa $i | grep -q $drive && echo $i; done`

#get the index number for the specific drive/JBOD combination
index=`for i in $(sg_map -i | awk '!/ATA/ {print $1}'); do sg_ses -p 0xa $i; done | grep $drive -B8 | grep Element | awk '{print$3}'`
echo $index

if [ "$2" == "set" ]
then
   sg_ses --index=$index --set=ident $array
elif [ "$2" == "clear" ]
then
   sg_ses --index=$index --clear=ident $array
else
   echo "usage: drivefind.sh /dev/driveletter set/clear"
fi
