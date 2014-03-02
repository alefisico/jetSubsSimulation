#!/bin/bash
MAINDIR=`pwd`
DIRECTORY=${MAINDIR}/../cmsswlogs/DYDYJets_PU_532_AODSIM_

while read rline
do

CURRENT=$rline

done < ${MAINDOR}/currentjob.txt

#for the next 100 jobs, replace 1 with 101 in the below line
READ=`expr $CURRENT + 1`
DIRECTORY=$DIRECTORY$READ'.log'
CURRENT=`expr $CURRENT + 1`



while read line
do

input=`echo $line | awk '{split($line,a1,"CDT "); print(a1[2]);}'`

if [[ $input == Successfully* ]]; then
eval `/opt/condor/bin/condor_release 16980.$CURRENT`
echo $CURRENT > ${MAINDIR}/currentjob.txt
fi


done < $DIRECTORY

