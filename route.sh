#!/bin/bash

#$1 file
get_ip()
{
	file=$1
	while read -r line; do
		if [[ "$line" =~ ^#.* ]]; then
			continue
		fi
		line=${line%#*}
		echo $line
	done < $file
}

#$1 ip_list $2 net if
add_route()
{
	ip_list=$1
	net_if=$2
	for ip in $ip_list; do
		route add $ip gw $net_if
		if [ $? -ne 0 ]; then
			logger -p local1.error  -t "VPN" -i "add $ip to route fail"
		fi
	done
}

#$1 ip_list $2 net if
remove_route()
{
	ip_list=$1
	net_if=$2
	for ip in $ip_list; do
		route del $ip gw $net_if
		if [ $? -ne 0 ]; then
			logger -p local1.error  -t "VPN" -i "remove $ip to route fail"
		fi
	done
}

#$1 file $2 add/remove $3 net if or gw
main()
{
	if [ $# -ne 3 ]; then
		logger -p local1.error  -t "VPN" -i "param less than 3"
		exit 1
	fi

	if [ -f $1 ]; then
		logger -p local1.error  -t "VPN" -i "$1 file not exist"
		exit 1
	fi 

	case "$2" in
	"add")
		file=$1
		ip_list=$(get_ip $file)
		add_route "$ip_list" $3
	;;
	"remove")
		file=$1
		ip_list=$(get_ip $file)
		remove_route "$ip_list" $3
	;;
	*)
		echo "USAGE: route [add,remove]"; exit 1
	;;
	esac
}

main $1 $2 $3
