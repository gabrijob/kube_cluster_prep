#/!/bin/bash

datasets_dir=$(pwd)
source $datasets_dir/workload_generator_function.sh

if [[ $# -lt 1 ]] ; then
	echo "Usage: $ generate_dataset.sh CONFIG_FILE_PATH"
	exit 1
fi

# Load config file
source $1

case $BENCHMARK in
	
	TEA)
		teastore_load_generator $DURATION $STEP $WEBUI_ADDR "http://$PROMETHEUS_URL"
		;;
	SOCNET)
		socialnetwork_load_generator $DURATION $STEP $WEBUI_ADDR "http://$PROMETHEUS_URL" $SOCIAL_GRAPH
		;;
	HOTEL)
		hotelreservation_load_generator $DURATION $STEP $WEBUI_ADDR "http://$PROMETHEUS_URL"
		;;

	*)
		echo "Benchmark not implemented"	
esac
