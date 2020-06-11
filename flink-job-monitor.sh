#!/usr/bin/env bash

to="****@qq.com"
email_title="flink 任务异常告警"
email_content=""

flink list  > monitor.log
cat monitor.log | grep -A 50 -i 'Running/Restarting Jobs'  > current.out
cut -d ":" -f 5 current.out > job-list.log
sed -i '1d' job-list.log
sed -i '$d' job-list.log
sed -i '$d' job-list.log
cut  -d "(" -f 1  job-list.log > job-list.out
if [ ! -f current-job.log ]; then
 cut  -d "(" -f 1  job-list.log > current-job.log
fi

job_array=($(awk '{print $1}' job-list.out))
current_job_array=($(awk '{print $1}' current-job.log))
jr_size=${#job_array[*]}
cjr_size=${#current_job_array[*]}

#判断任务状态是否正常
if [ ${jr_size} -lt ${cjr_size} ]; then
 for i in ${current_job_array[@]};
 do
    j=`cat job-list.out | grep ${i}`
    if [ ! -n "${j}" ];then
       str=${str}${i}","
    fi
 done
fi

if [ ${str} ];then
  email_content=${str}
  echo "${email_content}" | mail -s "${email_title}"  -t ${to}
fi
