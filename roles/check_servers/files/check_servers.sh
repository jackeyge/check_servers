install_jo() {
    wget https://github.com/jpmens/jo/releases/download/v1.1/jo-1.1.tar.gz
    tar zxf jo-1.1.tar.gz 
    cd jo-1.1
    ./configure && make && make install
	cd ../
	rm -rf jo-1.1*
}

get_hostname() {
    host_name=`hostname`
	echo "hostname=$host_name" >> tmp.txt
}

get_ip() {
    net_list=`ls /sys/class/net | grep -v docker0 | grep -v lo`
	>net.txt
	# get ip list
	for net in $net_list
	do
		ip=`ifconfig $net | grep 'inet ' | awk '{print $2}'`
		if [ ! -n "$ip" ] ;then
			break
		fi
		echo  "$net=$ip" >> net.txt
	done
	# create json
	net_ip_json=`cat net.txt | jo`
	rm -f net.txt
	echo "ip_list=$net_ip_json" >> tmp.txt
}

get_os() {
	redhat_rels=`cat /etc/redhat-release`
	echo "os_version=$redhat_rels" >> tmp.txt
}

get_cpu() {
	cpu_num=`lscpu | grep "^CPU(s):" | awk '{print $2}'`
	echo "cpu_number=$cpu_num" >> tmp.txt
}

get_mem() {
	mem_to=`free -h | grep Mem | awk '{print $2}'`
	echo "mem_total=$mem_to" >> tmp.txt
}

get_disk() {
	disk_json=`lsblk | grep disk | awk '{print $1"="$4}'|jo`
	echo "disk_list=$disk_json" >> tmp.txt
}

network_connectivity() {
	#ping -c 10 -q $internet_domain | grep received | awk '{print $4}'  
	gw=`route -n | grep UG | awk '{print $2}'|head -1`
    timeout=60    
    target=www.baidu.com
    # connect gw 
     ping -c2 -i0.3 -W1 $gw &>/dev/null
	 #echo $?
     if [ $? -eq 0 ];then
        connect_gw="True" 
     else
        connect_gw="False" 
     fi	
	 echo "connect_getway=$connect_gw" >> tmp.txt
    #get http code    
    ret_code=`curl -I -s --connect-timeout $timeout $target -w %{http_code} | tail -n1`    
        
    if [ "x$ret_code" = "x200" ]; then    
		internet="True"
    else    
		internet="False"
    fi 
    echo "connect_internet=$internet" >> tmp.txt	
}



main() {
	>tmp.txt
	get_hostname
	get_ip
	get_os
	get_cpu
	get_mem
	get_disk
	network_connectivity
	cat tmp.txt | jo -p
	rm -f tmp.txt
}

main
