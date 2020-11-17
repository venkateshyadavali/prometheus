#!/bin/bash
  
# Monitor services that are running. Check state of services and push the metrics to Pushgateway which would be scraped by prometheus
# - Services monitored on AGW
#       vbscd (process vbscmain, auditProcess, logWriterVbsc)
#       rtpproxyd (process RtpProxy, logWriterRtp)
#       mysql
#       omc
#       omcgui

services=(vbscd rtpproxyd mysql omc omcgui)

i=0
echo "# TYPE service_status gauge" > /home/altoUser/service_mon_output.txt

while [ $i -lt ${#services[@]} ]
do
#    echo " service name is : ${services[$i]}"
    z=`/sbin/service "${services[$i]}" status`
#    echo "service ${services[$i]} status is \n $z"
    while read -r line
    do
#        echo "Process line $line is under ${services[$i]}"
        if_running=`echo "$line" | grep running | wc -l`
        process=`echo "$line" | awk '{ print $1 }'`
        echo "service_status{service=\"${services[$i]}\",process=\"$process\",node=\"2g-agw\"} $if_running" >> /home/altoUser/service_mon_output.txt
        #if [[ $if_running != 0 ]]
        #then echo "service_status{service=\"${services[$i]}\",process=\"$process\",node=\"2g-agw\"} 1" >> /home/altoUser/service_mon_output.txt
        #fi
    done <<< "$z"
i=`expr $i + 1`
done

cat /home/altoUser/service_mon_output.txt | curl --data-binary @- http://192.168.100.35:9091/metrics/job/service/instance/2g-agw
