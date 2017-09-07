#!/bin/bash

function usage() {
cat <<EOF
用法: $(basename $0) <文件名> [true]
  计算指定文件中奇偶行的时间差，并求其平均值。
如果指定第二个参数，这显示每个时间差。
EOF
}

function create_odd_even_file() {
    sed -n -e '1~2{s/\(^.\{23\}\).*/\1/;p}' $1 >.tmp1.txt
    sed -n -e '2~2{s/\(^.\{23\}\).*/\1/;p}' $1 >.tmp2.txt
}

function datetime2second() {
    while read line
    do
	echo $(date -d "${line%.*}" +%s).${line#*.}
    done < $1
}


function evaluate() {
    create_odd_even_file $1
    datetime2second .tmp1.txt > .tmp1_time.txt
    datetime2second .tmp2.txt > .tmp2_time.txt
    
    local sum="0"
    local value=0
    local count=0
    paste -d - .tmp2_time.txt .tmp1_time.txt > .tmp2_tmp1.txt
    while read line
    do
	((count++))
	result=$(echo "$line" | bc)
	if [[ -n "$2" ]]; then
	    printf "%s: %s\n" "${count}x1" "${result}"
	fi
	sum=$(echo "${sum} + ${result}" | bc)
    done < .tmp2_tmp1.txt
    
    echo "Items: $count, Sum: $sum, AVG: "$(echo "scale=3;${sum} / 200.0" | bc)

    rm -rf .tmp1.txt .tmp2.txt .tmp1.time.txt .tmp2_time.txt .tmp2_tmp1.txt
}

if [[ "$1" ]]; then
    evaluate $@
else
    usage
fi
