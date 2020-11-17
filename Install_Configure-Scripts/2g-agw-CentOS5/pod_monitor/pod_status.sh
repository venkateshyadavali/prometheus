#!/bin/bash
  
# Read all the files in /audit/open and read each line of the file to check for status of pod
# - File name would be of the format: GrdGwAudit_*.log
# - Sample log which shows POD status:
# 31-08-2020-12:04:09,1598875449,-,-,ORANGE_TBC-003-SALA,AGLM_LINK_DOWN,-,-,-,-,-,-,0,-,-,-
# 31-08-2020-12:04:16,1598875456,-,-,ORANGE_TBC-003-SALA,RGW_PAGIN_LINK_UP,-,-,-,-,-,-,-,-,-,-
# 31-08-2020-12:04:16,1598875456,-,-,ORANGE_TBC-003-SALA,RGW_LOGON_MSG,-,-,-,-,-,-,-,-,-,MT_V=On, MT_SMS=On : MT Attrs Not Incl
# 5th field is POD ID. Ex: ORANGE_TBC-003-SALA; Status is in 6th field

#searchDir="/home/ubuntu/pod/log/"

cd /audit/open
for file in /audit/open/*
do
#    echo "$(basename "$file")"
    filename="$file"
    while IFS= read -r line
    do
        IFS=','
        read -a strarr <<< "$line"
        #printf "POD ID is ${strarr[4]}\n"
        #printf "POD Status is ${strarr[5]}\n"
        if [ ${strarr[5]} == "AGLM_LINK_DOWN" ]
        then
            #echo "IF condition - link down"
            #echo "${strarr[4]}, ${strarr[5]}, 0" > /home/ubuntu/pod/status/${strarr[4]}.txt
            echo "pod_status{RGWID=\"${strarr[4]}\",OP=\"${strarr[5]}\"} 0" > /home/altoUser/pod_monitor/status/${strarr[4]}.txt
        elif [ ${strarr[5]} == "RGW_PAGIN_LINK_UP" ] || [ ${strarr[5]} == "RGW_LOGON_MSG" ]
        then
            #echo "Else condition - link UP"
            #echo "${strarr[4]}, ${strarr[5]}, 1" > /home/ubuntu/pod/status/${strarr[4]}.txt
            echo "pod_status{RGWID=\"${strarr[4]}\",OP=\"${strarr[5]}\"} 1" > /home/altoUser/pod_monitor/status/${strarr[4]}.txt
        fi
    done < "$filename"
#    echo "Populate $file data to prometheus"
done

for files in /home/altoUser/pod_monitor/status/*
do
    sed -i '1s;^;# TYPE pod_status gauge\n;' $files
#    cat "$files"
    cat "$files" | curl --data-binary @- http://192.168.100.35:9091/metrics/job/pod/instance/2g-agw
done
