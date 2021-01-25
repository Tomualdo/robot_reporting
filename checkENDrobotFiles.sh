#!/bin/bash

mainPe02=173
mainPe03=174
kappaGamma03=175
kappaGamma05=176
mainQl02=177
mainQl03=178
lntDpf01_02_LH=185
lntDpf01_02_RH=186
lntDpf01_03_LH=187
lntDpf01_03_RH=188
lntDpf01_04=189
lntDpf01_06=190
ctr=191
scr1=197
scr2=198
scr3=199
lntDpf02_02_RH=200
lntDpf02_03_RH=201
lntDpf02_04=202
lntDpf02_06=203
lntDpf02_02_LH=204
lntDpf02_03_LH=205
lntDpf01_SPOT_1=206
lntDpf01_SPOT_2=207
lntDpf02_SPOT_1=208
lntDpf02_SPOT_2=209
STF_DPF=210
STF_SCR=211

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

echo "Checking difference in HEAD for files at $SUBDIR1 <--> $SUBDIR2"

for MAINDIR in $BASEDIR/* ;do                                                                       # Line name DIR
    [ -d $MAINDIR ] && JOBDIR1=$MAINDIR/$SUBDIR1 && JOBDIR2=$MAINDIR/$SUBDIR2 || continue           #/home/tom/Projects/proface/robotFiles/ctr/ *DATE* - 2 day /

    for JOBFILES1 in $JOBDIR1/* ;do
        #CHECK IF IT IS A FILE
        [[ -f "$JOBFILES1" ]] || continue 

        #CHECK EXTENSION xxxx.JOB
        [[ "$JOBFILES1" =~ [0-9]*[.]JOB ]] || continue 

        #CHECK FOR "END" AT THE END OF ROBOT PROGRAM
        if ! [[ "$(tail -n1 $JOBFILES1)" =~ END ]] ;then

            # IF NOT FOUND > INFOMR ME ABOUT FILE
            echo -e "\n\n\t\t\033[0;30m\e[103m-----------$JOBFILES1--------------\e[7mEND NOT FOUND\e[0m\n"

            #SET OUTPUT COLOR
            echo -e "\e[30m\e[101m" 

            #PRINT PROBLEMATIC FILE
            cat $JOBFILES1
            echo -e "\e[0m"
            echo -e "\e[97m\e[44mTrying to download again...$JOBFILES1\033[0;00m\n"
            
            #set VARs:
            LINKA=$(echo $JOBFILES1 | cut -d"/" -f7)
            DATUM=$(echo $JOBFILES1 | cut -d"/" -f8)
            JOB=$(echo $JOBFILES1 | cut -d"/" -f9 | cut -d"." -f1)
            IP=${!LINKA}
            
            #RUN DOWNLOAD
            /home/tom/Projects/proface/robotFiles/robotProgram.py $LINKA $IP $DATUM $JOB

            #PRINT RESULT
            echo -e "\e[97m\e[44m$(date +%y%m%d-%H:%M:%S)--DONE DOWNLOAD...\033[0;00m\n"
            echo -e "\e[30m\e[42m" #SET OUTPUT COLOR AFTER DOWNLAD
            cat $JOBFILES1
            echo -e "\e[0m"
        fi 

done
done
