#!/bin/bash

BASEDIR=/home/tom/Projects/proface/robotFiles
SUBDIR1=`date --date '-1 day' +%Y%m%d`
SUBDIR2=`date --date '-2 day' +%Y%m%d`

if [ $(date +%u) = 1 ] ; then #check if is Monday
    echo Is Monday
    SUBDIR1=`date --date '-2 day' +%Y%m%d` #check SATURDAY backup
    SUBDIR2=`date --date '-3 day' +%Y%m%d` #check FRIDAY backup
fi

if [ $(date +%u) = 2 ] ; then #check if is TUESDAY
    echo Is Tuesday
    SUBDIR1=`date --date '-1 day' +%Y%m%d` #check MONADY backup
    SUBDIR2=`date --date '-3 day' +%Y%m%d` #check SATURDAY backup
fi

TODAYDIR=`date +%y%m%d`
TODAYTIME=`date +%H%M%S`

#echo "Checking difference of files at $SUBDIR1 <--> $SUBDIR2"

#mkdir -p $BASEDIR/diffHistory/$TODAYDIR
for MAINDIR in $BASEDIR/* ;do                                                                       # Line name DIR
    [ -d $MAINDIR ] && JOBDIR1=$MAINDIR/$SUBDIR1 && JOBDIR2=$MAINDIR/$SUBDIR2 || continue           #/home/tom/Projects/proface/robotFiles/ctr/ *DATE* - 2 day /

    for JOBFILES1 in $JOBDIR1/* ;do
        #JOBFILE2EXT=`echo $JOBFILES1 | grep -o ".....JOB"`  # cut only 0001.JOB
        #JOBFILES2=$JOBDIR2/$JOBFILE2EXT                     #...20200408/0001.JOB
        #echo $JOBFILES1
        [[ -f "$JOBFILES1" ]] || continue 
        [[ "$JOBFILES1" =~ [0-9]*[.]JOB ]] || continue 
        #diff -u --color=always $JOBFILES1 $JOBFILES2 >> $BASEDIR/diffHistory/$TODAYDIR/$TODAYTIME.log 
        #diff -u --color=always $JOBFILES1 $JOBFILES2
        #[ $(tail -n1 $JOBFILES1 | cut -d" " -f6 | tr -d '\r\n') = "END" ] && echo "$JOBFILES1 - OK" || echo "$JOBFILES1 - NG !!"
        [[ $(head -n1 "$JOBFILES1" | cut -d" " -f1 | tr -d '\r\n') = "Program" ]] || echo -e "\n\n\t\t\033[0;32m\e[103m-----------$JOBFILES1--------------\033[0;00m\n"
        [[ $(head -n1 "$JOBFILES1" | cut -d" " -f1 | tr -d '\r\n') = "Program" ]] || cat $JOBFILES1
        #test=$(tail -n1 $JOBFILES1 | cut -d" " -f6) && echo "$JOBFILES1 -----$test"
done
done
