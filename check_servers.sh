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
}

get_ip() {
    net_list=`ls /sys/class/net | grep -v docker0 | grep -v lo`
	>net.txt
	for net in $net_list
	do
		ip=`ifconfig $net | grep 'inet ' | awk '{print $2}'`
		echo  "$net $ip" >> net.txt
	done
}

get_ip