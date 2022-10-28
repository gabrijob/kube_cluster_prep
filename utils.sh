#/!/bin/bash

##############################################################
local_connection (){
	#ssh-keygen -t rsa
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
	chmod og-wx ~/.ssh/authorized_keys 	
}
#############################################################
nodefile_verification (){
	nodefile=$1
	dir=$2
	if [ -f $dir/$nodefile ]
	then
        	echo "Loading nodefile: $nodefile..." 
   	else
		echo "$nodefile not found..."
		echo "Please, create a nodefile list!"
		exit 0
	fi
	[ ! -s $dir/$nodefile ] && echo "The nodefile file is empty..." && exit 0

}
###############################################################
#this function can be used if there is some problem of the key in known_hosts
update-local-key () {
  	localuser=$USER
  	nodefile=$1
  	dir=$2
  	echo "updating keys from local node to the allocated ones"
  	for i in `cat $dir/$nodefile`;
	do	
		ssh-keygen -f "/home/$localuser/.ssh/known_hosts" -R $i 
  	done
}

###############################################################

discovery-cluster(){
	nodefile=$1
	dir=$2
	echo "Trying to create the file: " $nodefile 
	for i in `uniq $OAR_NODE_FILE | cut -d "."  -f1 `;
	do
		echo $i >> $dir/$nodefile
		echo $i"-ib0" >> $dir/$nodefile"1"
	done

}
