#/!/bin/bash

datasets_dir=$(pwd)
source $datasets_dir/workload_generator_functions.sh

if [[ $# -lt 1 ]] ; then
	echo "Usage: $ generate_dataset.sh CONFIG_FILE_PATH"
	exit 1
fi

# Load config file
source $1

case $BENCHMARK in
	
	TEA)
		teastore_load_generator $DURATION $WEBUI_ADDR $PROMETHEUS_URL
		;;
	SOCNET)
		socialnetwork_load_generator $DURATION $WEBUI_ADDR $PROMETHEUS_URL $SOCIAL_GRAPH
		;;
	HOTEL)
		hotelreservation_load_generator $DURATION $WEBUI_ADDR $PROMETHEUS_URL
		;;

	*)
		echo "Benchmark not implemented"	
esac
