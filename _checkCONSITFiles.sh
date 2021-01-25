#!/bin/bash

#ROBOT IP LIST
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
###################

#SOME VARS FOR STATISTIC
let FILES_CHECKED=0
let FILES_NG=0
let FILES_REPAIRED=0
let FILES_RETRY=0

###################

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

#ARG FOR DATE OFFSET
[ "$1" -ge 2 ] && SUBDIR1=$(eval "date --date '-$1 day' +%Y%m%d")

#ARG1 FOR TODAY CALCULATION
[ "$1" = "-t" ] && SUBDIR1=`date +%Y%m%d` && SUBDIR2=`date --date '-1 day' +%Y%m%d`


TODAYDIR=`date +%y%m%d`
TODAYTIME=`date +%H%M%S`

printStats(){

    echo -en "Checked Files:\t$FILES_CHECKED\nFiles NG:\t$FILES_NG\nFiles Repaired:\t$FILES_REPAIRED\nFiles Retry:\t$FILES_RETRY\n" 

}
endCheckFunc(){
    #CHECK FOR "END" AT THE ***END*** OF ROBOT PROGRAM
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
}

startCheckFunc(){
    #STAT UPDATE
    [ "$RETRY" -eq "0" ] && let FILES_CHECKED++
    #VISUAL OUTPUT
    echo -ne "checking\t$JOBFILES1"
    #CLEAR THE OUTPUT LINE WITH SPACEEEEES
    echo -ne "                                                                                             \r"

    #CHECK FOR "Program" AT THE ***START*** OF ROBOT PROGRAM
    if ! [[ "$(head -n1 $JOBFILES1)" =~ Program ]] ;then

        #STAT UPDATE
        let FILES_NG++

        # IF NOT FOUND > INFOMR ME ABOUT FILE
        echo -e "\n\n\t\t\033[0;30m\e[103m-----------$JOBFILES1--------------\e[7mSTART Program NOT FOUND\e[0m\n"

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
        echo -e "\e[97m\e[44m$(date +%y%m%d-%H:%M:%S)--DONE DOWNLOAD...\e[0m\n"

        #CHECK AGAIN THE HEAD
        if [[ "$(head -n1 $JOBFILES1)" =~ Program ]];then 
            #STAT UPDATE
            [ "$RETRY" -eq "0" ] && let FILES_REPAIRED++
            [ "$RETRY" -ge "1" ] && let FILES_RETRY++ && let FILES_REPAIRED++

            #PRINT OK RESULT
            echo -e "\e[30m\e[42m" #SET OUTPUT COLOR AFTER DOWNLAD
            cat $JOBFILES1
            echo -e "\e[0m"
        else
            #PRINT NG RESULT
            echo -e "\e[30m\e[105m" #SET OUTPUT COLOR AFTER DOWNLAD
            cat $JOBFILES1
            echo -e "\e[0m"
            #RETRY
            #SET FLAG
            let RETRY++
            echo -e "\e[31m\e[106mRETRY $RETRY Download\e[0m\n"
            [ "$RETRY" -le 3 ] && startCheckFunc #TRY DOWNLAD MAX 3xTIMES
        fi
    fi 
}

#################################################################################################################
#echo -en "\n\t\t\e[7mChecking difference in HEAD for files at $SUBDIR1 <--> $SUBDIR2\e[0m\r"
echo -en "\n\t\t\e[7mChecking difference in HEAD for files at $SUBDIR1\e[0m\r"
echo -ne "\n"

for MAINDIR in $BASEDIR/* ;do                                                                       # Line name DIR
    [ -d $MAINDIR ] && JOBDIR1=$MAINDIR/$SUBDIR1 && JOBDIR2=$MAINDIR/$SUBDIR2 || continue           #/home/tom/Projects/proface/robotFiles/ctr/ *DATE* - 2 day /

    for JOBFILES1 in $JOBDIR1/* ;do
        #CHECK IF IT IS A FILE
        [[ -f "$JOBFILES1" ]] || continue
        #CHECK EXTENSION xxxx.JOB
        [[ "$JOBFILES1" =~ [0-9]*[.]JOB ]] || continue 
        #RESET RETRY FLAG
        let RETRY=0
        startCheckFunc

done
done
#new line for clear terminal
echo -en "\n"

#Print final STATISTIC DATA
printStats
