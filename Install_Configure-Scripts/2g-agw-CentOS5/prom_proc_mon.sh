#!/bin/bash
arr=(/usr/sbin/mysqld /usr/local/rtpproxy/bin/RtpProxy /usr/local/vbsc/tools/MonitorVBSCProcess /usr/bin/MonitorOMCProcess) 
i=0 
echo "# TYPE process_status counter" > /home/altoUser/proc_mon_output.txt

while [ $i -lt ${#arr[@]} ] 
do
#    echo ${arr[$i]}
    z=`ps aux | grep "${arr[$i]}" | grep -v grep`
    wc=`ps -ef | grep "${arr[$i]}" | grep -v grep | wc -l`
    if [ $wc == 0 ]; then
        echo "process_status{process=\"${arr[$i]}\",node=\"2g-agw\",pid=\"Nil\"} 0" >> /home/altoUser/proc_mon_output.txt
#        var=$var$echo "process_status{process=\"${arr[$i]}\"} 0"
    else
        while read -r z
        do
            var_pid=`awk '{ print $2 }'`
#            var_pid=$(awk '{ print $2 }')
#            echo $var_pid
            echo "process_status{process=\"${arr[$i]}\",node=\"2g-agw\",pid=\""$var_pid"\"} 1" >> /home/altoUser/proc_mon_output.txt
#            unset var_pid
#            var_pid=""
#            cmd=`awk '{ print $11 } '`
#            var=$var$(awk '{print "process_status{process=\""$11"\"}", $3z}');
#            echo "process_status{process=\"$11\"} 1" >> proc_mon_output.txt
##            awk '{ print "process_status{process=\""$11"\"} 1" }' >> proc_mon_output.txt

        done <<< "$z"
    fi
    i=`expr $i + 1` 

done

cat /home/altoUser/proc_mon_output.txt | curl --data-binary @- http://192.168.100.35:9091/metrics/job/ps/instance/2g-agw
