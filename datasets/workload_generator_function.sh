#/!/bin/bash

dir=$(pwd)

################################################### TeaStore load generator ###########################################################
teastore_load_generator() {
	duration_h=$1
	time_step=$2
	webui_addr=$3
	prometheus_url=$4
	sed_str="s/http:\/\/.*\/t/http:\/\/${webui_addr}\/t/"

	echo "TeaStore Workload Generation"

	for REQUEST in teastore_browse teastore_buy; do
		sed -i "$sed_str" $dir/httploadgenerator/$REQUEST.lua

		for INTENSITY in sinLowDenseIntensity sinLowSparseIntensity sinMedDenseIntensity sinMedSparseIntensity sinHighDenseIntensity sinHighSparseIntensity; do 
			begin_t=$(date +%s)
			end_t=$(date -d "+${duration_h} hours" +%s)
			now_t=$(date +%s)
			
			echo "----- Starting workload $REQUEST with intensity $INTENSITY for $duration_h hours -----"
			while [ $begin_t -le $now_t -a $now_t -le $end_t  ]; do
				outfile="out_${REQUEST}_${INTENSITY}_${now_t}"
				java -jar $dir/httploadgenerator/httploadgenerator.jar loadgenerator &
				java -jar $dir/httploadgenerator/httploadgenerator.jar director -s localhost -a $dir/httploadgenerator/$INTENSITY.csv -l $dir/httploadgenerator/$REQUEST.lua -o $outfile.csv -t 256
				kill $(pidof java)
				sleep 5
				now_t=$(date +%s)

			done
			python3 $dir/prometheus_fetch.py $prometheus_url -N "${REQUEST}_${INTENSITY}" -t $duration_h -s $time_step -c $dir/metrics.ini
		done
	done
#CLEANUP: kubectl delete all --all
}
#######################################################################################################################################

######################################## DeathStarBench's Social Network load generator ###############################################
socialnetwork_load_generator() {
	duration_h=$1
	time_step=$2
	webui_addr=$3
	prometheus_url=$4
	social_graph=$5
	ip_port_split=(${3//:/ })
	duration_s=$((60*60*duration_h))
	
	echo "DeathStarBench's Social Network Workload Generation"

	#python3 datasets/social_network/init_social_graph.py --graph=$social_graph --ip ${ip_port_split[0]} --port ${ip_port_split[1]}
	cd $dir/wrk2
	make
	cd ..

	for INTENSITY in 10 50 100; do
		
		# Compose Post
		echo "----- Starting workload socialnetwork_compose_post with intensity $INTENSITY for $duration_h hours -----"
		./wrk2/wrk -D exp -t 4 -c 4 -d $duration_s -L -s ./wrk2/scripts/social-network/compose-post.lua "http://$webui_addr/wrk2-api/post/compose" -R $INTENSITY
		python3 $dir/prometheus_fetch.py $prometheus_url -N "socialnetwork_compose_post_${INTENSITY}" -t $duration_h -s $time_step -c $dir/metrics.ini

		# Read Home Timeline
		echo "----- Starting workload socialnetwork_read_home_timeline with intensity $INTENSITY for $duration_h hours -----"
		./wrk2/wrk -D exp -t 4 -c 4 -d $duration_s -L -s ./wrk2/scripts/social-network/read-home-timeline.lua "http://$webui_addr/wrk2-api/home-timeline/read" -R $INTENSITY
		python3 $dir/prometheus_fetch.py $prometheus_url -N "socialnetwork_read_home_timeline_${INTENSITY}" -t $duration_h -s $time_step -c $dir/metrics.ini

		# Read User Timeline
		echo "----- Starting workload socialnetwork_read_user_timeline with intensity $INTENSITY for $duration_h hours -----"
		./wrk2/wrk -D exp -t 4 -c 4 -d $duration_s -L -s ./wrk2/scripts/social-network/read-user-timeline.lua "http://$webui_addr/wrk2-api/user-timeline/read" -R $INTENSITY
		python3 $dir/prometheus_fetch.py $prometheus_url -N "socialnetwork_read_user_timeline_${INTENSITY}" -t $duration_h -s $time_step -c $dir/metrics.ini


	done
	cd $dir/wrk2
	make clean
	cd ..
}
#####################################################################################################################################

################################## DeathStarBench's Hotel Reservation load generator ################################################
hotelreservation_load_generator() {
	duration_h=$1
	time_step=$2
	webui_addr=$3
	prometheus_url=$4
	duration_s=$((60*60*duration_h))

	echo "DeathStarBench's Hotel Reservation Workload Generation"

	casts_path="$dir/media-microservices/casts.json"
	movies_path="$dir/media-microservices/movies.json"
	python3 $dir/media-microservices/write_movie_info.py -c $casts_path -m $movies_path --server_address $webui_addr && $dir/media-microservices/register_users.sh 	&& $dir/media-microservices/register_movies.sh

	cd $dir/wrk2
	make
	cd ..

	for INTENSITY in 10 50 100; do

		# Compose Review
		echo "----- Starting workload mediamicroservices_compose_review with intensity $INTENSITY for $duration_h hours -----"
		./wrk2/wrk -D exp -t 4 -c 4 -d $duration_s -L -s ./wrk2/scripts/media-microservices/compose-review.lua \ 
			"$webui_addr/wrk2-api/review/compose" -R $INTENSITY
		python3 $dir/prometheus_fetch.py $promehtues_url -N "mediamicroservices_compose_review_${INTENSITY}" -t $duration_h -s $time_step -c $dir/metrics.ini
	
	done

	cd $dir/wrk2
	make clean
	cd ..
}
#####################################################################################################################################

##################################### DeathStarBench's Media Service load generator #################################################
mediaservice_load_generator() {	
	echo "DeathStarBench's Media Service Workload Generation"
}
#####################################################################################################################################

############################################## TrainTicket load generator ###########################################################
trainticket_load_generator() {
	echo "TrainTicket Workload Generation"
}
#####################################################################################################################################

