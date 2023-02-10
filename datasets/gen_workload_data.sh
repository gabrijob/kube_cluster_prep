#/!/bin/bash

dir="/home/ggrabher/kube_cluster_prep"
PROMETHEUS_ADDR='http://172.16.52.9:30090'
DURATION_H=1

if [[ $# -lt 2 ]] ; then
	echo "Usage: $ gen_workload_data.sh BENCHMARK_NAME WEBUI_ADDRESS"
	echo "- BENCHMARK in ['TEA', 'SOCNET', 'HOTEL', 'MEDIA', 'TRAIN']"
	exit 1
fi

#TODO: read from config file
#### TeaStore load generator #####
if [ $1 = 'TEA' ]; then
	echo "TeaStore Workload Generation"
	WEBUI_ADDR=$2
	sed_str="s/http:\/\/.*\/t/http:\/\/${WEBUI_ADDR}\/t/"
	
	java -jar $dir/datasets/httploadgenerator/httploadgenerator.jar loadgenerator &

	for REQUEST in teastore_browse teastore_buy; do
		sed -i "$sed_str" $dir/datasets/httploadgenerator/$REQUEST.lua

		for INTENSITY in increasingLowIntensity increasingMedIntensity increasingHighIntensity; do 
			begin_t=$(date +%s)
			end_t=$(date -d "+${DURATION_H} hours" +%s)
			now_t=$(date +%s)
			
			echo "----- Starting workload $REQUEST with intensity $INTENSITY for $DURATION_H hours -----"
			while [ $begin_t -le $now_t -a $now_t -le $end_t  ]; do
				OUTFILE="out_${REQUEST}_${INTENSITY}_${now_t}"
				java -jar $dir/datasets/httploadgenerator/httploadgenerator.jar director -s localhost -a $dir/datasets/httploadgenerator/$INTENSITY.csv -l $dir/datasets/httploadgenerator/$REQUEST.lua -o $OUTFILE.csv -t 256
				now_t=$(date +%s)
			done
			python3 $dir/datasets/prometheus_fetch.py $PROMETHEUS_ADDR -n "${REQUEST}_${INTENSITY}" -t $DURATION_H
		done
	done
	kill $(pidof java)

##### DeathStarBench's Social Network load generator #####
elif [ $1 = 'SOCNET' ]; then
	echo "DeathStarBench's Social Network Workload Generation"
	WEB_SERVER_IP=$2
	ip_split=(${2//:/ })
	duration=$((60*60*DURATION_H))
	SOC_GRAPH='ego-twitter'
	
	python3 datasets/social_network/init_social_graph.py --graph=$SOC_GRAPH --ip ${ip_split[0]} --port ${ip_split[1]}
	cd $dir/datasets/wrk2
	make
	cd ..

	for INTENSITY in 10 50 100; do
		echo "----- Starting workload socialnetwork_compose_post with intensity $INTENSITY for $DURATION_H hours -----"
		./wrk2/wrk -D exp -t 4 -c 4 -d $duration -L -s ./wrk2/scripts/social-network/compose-post.lua "http://$WEB_SERVER_IP/wrk2-api/post/compose" -R $INTENSITY
		python3 $dir/datasets/prometheus_fetch.py $PROMETHEUS_ADDR -n "socialnetwork_compose_post_${INTENSITY}" -t $DURATION_H

		echo "----- Starting workload socialnetwork_read_home_timeline with intensity $INTENSITY for $DURATION_H hours -----"
		./wrk2/wrk -D exp -t 4 -c 4 -d $duration -L -s ./wrk2/scripts/social-network/read-home-timeline.lua "http://$WEB_SERVER_IP/wrk2-api/home-timeline/read" -R $INTENSITY
		python3 $dir/datasets/prometheus_fetch.py $PROMETHEUS_ADDR -n "socialnetwork_read_home_timeline_${INTENSITY}" -t $DURATION_H

		echo "----- Starting workload socialnetwork_read_user_timeline with intensity $INTENSITY for $DURATION_H hours -----"
		./wrk2/wrk -D exp -t 4 -c 4 -d $duration -L -s ./wrk2/scripts/social-network/read-user-timeline.lua "http://$WEB_SERVER_IP/wrk2-api/user-timeline/read" -R $INTENSITY
		python3 $dir/datasets/prometheus_fetch.py $PROMETHEUS_ADDR -n "socialnetwork_read_user_timeline_${INTENSITY}" -t $DURATION_H

	done
	cd $dir/datasets/wrk2
	make clean
	cd ..

##### DeathStarBench's Hotel Reservation load generator #####
elif [ $1 = 'HOTEL' ]; then
	echo "DeathStarBench's Hotel Reservation Workload Generation"
	WEB_SERVER_IP=$2
	SOC_GRAPH='ego-twitter'

	casts_path="$dir/datasets/media-microservices/casts.json"
	movies_path="$dir/datasets/media-microservices/movies.json"
	python3 $dir/datasets/media-microservices/write_movie_info.py -c $casts_path -m $movies_path --server_address $WEB_SERVER_IP && $dir/datasets/media-microservices/register_users.sh && $dir/datasets/media-microservices/register_movies.sh

	cd $dir/datasets/wrk2
	make
	cd ..

	for INTENSITY in 10 100 1000; do
		echo "----- Starting workload mediamicroservices_compose_review with intensity $INTENSITY for $DURATION_H hours -----"
		./wrk2/wrk -D exp -t 4 -c 4 -d $DURATION_H -L -s ./wrk2/scripts/media-microservices/compose-review.lua "$WEB_SERVER_IP/wrk2-api/review/compose" -R $INTENSITY
		python3 $dir/datasets/prometheus_fetch.py $PROMETHEUS_ADDR -n "mediamicroservices_compose_review_${INTENSITY}" -t $DURATION_H
	

	done
	cd $dir/datasets/wrk2
	make clean
	cd ..

##### DeathStarBench's Media Service load generator #####
elif [ $1 = 'MEDIA' ]; then
	echo "DeathStarBench's Media Service Workload Generation"

##### TrainTicket load generator #####
elif [ $1 = 'TRAIN' ]; then
	echo "TrainTicket Workload Generation"

##### Default #####
else
	echo "Unknown benchmark."
fi
