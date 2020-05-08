#!/usr/bin/env bash

function help_documents()
{
	echo "help_document [options][]"
	echo "options:"
	echo "-a          统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比"
	echo "-b          统计不同场上位置的球员数量、百分比"
	echo "-c          名字最长的球员是谁？名字最短的球员是谁？"
	echo "-d          年龄最大的球员是谁？年龄最小的球员是谁？"
	echo "-h          查看帮助信息"

}

#统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
function age_range()
{
	echo -e "统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比\n"
   	a=$(awk -F '\t' 'BEGIN{split("<20 20-30 >30",b)}
	{if($6<20)a[1]++;if($6>=20&&$6<=30)a[2]++;if($6>30)a[3]++}
	END{for(i in a)print a[i]}' ./worldcupplayerinfo.tsv)
   	sum=0
    	ages=($a)
    	for i in $a ;
	do
        sum=$(($sum+$i)) 
    	done
    	s=("<20" "20-30" ">30")
    	echo -e 'age\tcount\tporprotion'
    	for i in `seq 0 2`;
	do
        age=${ages[i]}
        p=`awk 'BEGIN{printf "%.2f\n",('${age}'/'$sum')}'`
        echo -e ${s[i]}\\t${age}\\t${p}
   	done
}

#统计不同场上位置的球员数量、百分比
function position_status()
{
	echo -e "统计不同场上位置的球员数量、百分比\n"
	c=`awk -F '\t' '{print $5}' ./worldcupplayerinfo.tsv|sort -r|uniq -c|awk '{print $1}'`
	p=`awk -F '\t' '{print $5}' ./worldcupplayerinfo.tsv|sort -r|uniq -c|awk '{print $2}'`
	sum=0
	count=($c)
	position=($p)

	for i in $c ;do
		sum=$(($sum+$i)) 
	done
    	n=${#count[@]}
    	echo -e '场上位置\t球员数量\t百分比\t'
	echo -e "\n"
    	for((i=0;i<n;i++));  
    	do   
        cc=${count[i]}
        p=`awk 'BEGIN{printf "%f\n",('${cc}'/'$sum')}'`
        echo -e ${position[i]}\\t${cc}\\t${p}        
    	done  
}

#名字最长的球员是谁？名字最短的球员是谁？
function name_length()
{
	echo -e "名字最长的球员是谁？名字最短的球员是谁？"
    	echo `awk -F '\t' 'BEGIN { max = 0}
       	{
            if (length($9)>max){
                 max=length($9);
                 name=$9;
                }
            } END { print "名字最长的是",name}' ./worldcupplayerinfo.tsv`
    echo `awk -F '\t' 'BEGIN{ min = 1999999 } {
            if (length($9)<min){
                 min=length($9);
                 name=$9;
            }
        } END {print "名字最短的是",name}' ./worldcupplayerinfo.tsv`
	echo -e "\n"
}

#年龄最大的球员是谁？年龄最小的球员是谁？
function age_sort()
{
	echo -e "年龄最大的球员是谁？年龄最小的球员是谁？"
   	echo `awk -F '\t' 'BEGIN {max = 0} {
        if ($6>max){
             max=$6;
             name=$9;
            }
        } END {print "年龄最大的是",name,"年纪是", max}' ./worldcupplayerinfo.tsv`
    	echo `awk -F '\t' 'BEGIN {min = 1999999} {
        if ($6<min){
             min=$6;
             name=$9;
            }
        } END {print "年龄最小的是",name,"年纪是", min}' ./worldcupplayerinfo.tsv`
	echo -e "\n"	
}

while [ "$1" != "" ]; do
	case $1 in
		-a ) age_range
			exit
			;;
		-b ) position_status
			exit
			;;
		-c ) name_length
			exit
			;;
		-d ) age_sort
			exit
			;;
		-h  ) help_documents
			exit
			;;
	esac
done


