#!/bin/bash/env bash

function helps(){
	echo "usage:[options][]"
	echo "options:"
	echo "-a          统计访问来源主机TOP 100和分别对应出现的总次数"
	echo "-b          统计访问来源主机TOP 100 IP和分别对应出现的总次数"
	echo "-c          统计最频繁被访问的URL TOP 100"
	echo "-d          统计不同响应状态码的出现次数和对应百分比"
	echo "-e          分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数"
	echo "-u [url]    给定URL输出TOP 100访问来源主机"
	echo "-h          查看帮助信息"
}

function host_top()
{
    echo "访问来源主机TOP 100和分别对应出现的总次数"
    t=`awk '{a[$1]+=1;} END {for(i in a){print a[i],i;}}'  ./web_log.tsv | sort -t " " -k 1 -n -r | head -n 100`
    echo "$t"
}

function ip_top()
{
    echo "访问来源主机TOP 100 IP和分别对应出现的总次数"
    awk -F '\t' 'NR>1{if($1~/([0-9]{1,3}\.){3}[0-9]{1,3}/){ip_num[$1]+=1;}}END{for(i in ip_num){printf("ip:%-30s\t%d\t\n",i,ip_num[i]);}}' ./web_log.tsv | sort -n -r -k 2 | head -n 100

}

function url_top()
{
 	echo "show_top100_url"
	awk -F '\t' 'NR>1{url_num[$5]+=1;}END{for(i in url_num){printf("url:%-60s\t%d\t\n",i,url_num[i]);}} ' ./web_log.tsv  | sort -n -r -k 2 | head -n 100

}

function responsecode_stat()
{
    echo "统计不同响应状态码的出现次数和对应百分比"

    echo "show_status_code"
	awk -F '\t' 'BEGIN{num=0;}NR>1{num+=1;status_num[$6]+=1;}END{for(i in status_num){printf("status:%d\tnum:%d\tpercentage:%.5f%\t\n",i,status_num[i],status_num[i]*100.0/num);}} ' ./web_log.tsv
}

function responsecode_top()
{
    echo "403 top10:"
	awk -F '\t' 'NR>1{if($6~/^403/){url_num[$5]+=1;}}END{for(i in url_num){printf("url:%-50s\t%d\t\n",i,url_num[i]);}} ' ./web_log.tsv  | sort -n -r -k 2 | head -n 10
	echo "404 top10:"
	awk -F '\t' 'NR>1{if($6~/^404/){url_num[$5]+=1;}}END{for(i in url_num){printf("url:%-50s\t%d\t\n",i,url_num[i]);}} ' ./web_log.tsv  | sort -n -r -k 2 | head -n 10
}

function url_host()
{
	echo "给定URL输出TOP 100访问来源主机"
	echo "Input URL: $1"
	url=$1
	awk -F '\t' 'NR>1{if($5=="'"${url}"'"){url_num[$1]+=1;}}END{for(i in url_num){printf("host:%-30s\t%d\t\n",i,url_num[i]);}} ' ./web_log.tsv  | sort -n -r -k 2 | head -n 100

}

while [ "$1" != "" ]; do
	case $1 in
		-a ) host_top
			exit
			;;
		-b ) ip_top
			exit
			;;
		-c ) url_top
			exit
			;;
		-d ) responsecode_stat
			exit
			;;
		-e ) responsecode_top
			exit
			;;
		-u ) url_host $OPTARG
			exit
			;;
		-h ) helps
			exit
			;;
	esac
done

