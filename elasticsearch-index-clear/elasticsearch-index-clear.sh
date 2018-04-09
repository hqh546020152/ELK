#!/bin/bash
#

#elasticsearch访问host与端口
server_name="localhost:9400"

#判断上方给出的URL能否访问
result=$(curl -o /dev/null -s -w %{http_code} $server_name)
[ $result -ne 200 ] && echo "elasticsearch访问失败，请检查" && exit 7

#获取所有索引
A=`curl -s "$server_name/_cat/indices?v" |grep "logstash-*" |awk '{print $3}'|sort -n`

#判断配置文件是否有误
while read LINE;do			   
    #空行跳过
	[ $LINE -z ] &> /dev/null
	[ $? -eq 0 ] && continue
    #注释行跳过
	echo $LINE |grep "#" &> /dev/null
	[ $? -eq 0 ] && continue
	A1=`echo $LINE | awk '{print $1}'`
	A2=`echo $LINE | awk '{print $2}'`
    #判断配置是否有效
	echo $A | grep $A1 &> /dev/null
	[ $? -ne 0 ] && echo "$A1 找不到该索引，请检查。" && exit 8
	let C=$A2+0 &> /dev/null
	[ $? -ne 0 ] && echo "$A2 不是一个数值，请检查。" && exit 8
done <  /root/.develop/elasticsearch-index-clear.conf

#获取当天日期，并转换为时间搓
DIT=`date +%Y-%m-%d`
DIT_date=`date -d "$DIT 00:00:00" +%s`
#定义一天等于多少秒
day_date=86400
while read LINE;do
	[ $LINE -z ] &> /dev/null
        [ $? -eq 0 ] && continue
	echo $LINE |grep "#" &> /dev/null
        [ $? -eq 0 ] && continue
	A1=`echo $LINE | awk '{print $1}'`
	A2=`echo $LINE | awk '{print $2}'`
	#计算保留天数的总秒数
	let time_D=$A2*$day_date
	#获取与配置文件中匹配的索引名称
	B=`curl -s "$server_name/_cat/indices?v" |grep "$A1" |awk '{print $3}'|sort -n`

	#时间判断循环
	for index in $B;do
		#获取索引中的日期
		C=${index##*-}
		#转化日期格式，由于2018.01.01转化为2018-01-01
		D=`echo "$C" |sed 's/\./\-/g'`
		#将索引日期转化为时间搓
		E=`date -d "$D 00:00:00" +%s`
		#索引日期与当天日期对比
		let F=$DIT_date-$E
	
		#判断时间是否超过保留天数,并作出相应处理	
		if [ $F -gt $time_D ];then
			#以下为超过保留天数执行的命令
			echo "删除$index 索引"
			curl -XDELETE "$server_name/$index?pretty"
		fi
	done
done <  /root/.develop/elasticsearch-index-clear.conf
