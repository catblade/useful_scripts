#!/bin/bash

#  script for checking if a disk is full and reporting through AWS if it is.
#  Usage should be self-explanatory.  I hope.

if  [ $# -lt 5 ]
then
	echo "usage: aws_diskfull_checker.sh <percentage> <max days old> <file sizes> <topic> devices"
	echo "example: aws_diskfull_checker.sh 95 2 100M arn:aws:sns:us-east-1:493847008801:SpecialMarlow /dev/xvda1 /dev/md0"
	exit 1
fi

# disk percentage to alarm at
percentage=$1; shift

# oldest age of files that we care about
age=$1; shift

# size of files to report
size=$1; shift

# topic to alarm to
topic=$1; shift

# Devices to check
declare -a devnames=$@

for devname in $devnames
do
  let p=`df -k $devname | grep -v ^File | awk '{printf ("%i",$3*100 / $2); }'`
  if [ $p -ge $percentage ]
  then
    out=`df -h $devname`
    directories=`du -ah / 2>/dev/null | sort -n -r | head -n 10`
    files=`find /  -mtime -$age -size $size  -exec ls -lh {} + 2>/dev/null`
    aws sns publish --topic-arn $topic --message "On cron, $devname is low on space. $out Top Directories: $directories files: $files"
  fi
done