#/!/bin/bash

datasets_dir=$(pwd)
source $datasets_dir/workload_generator_function.sh

if [[ $# -lt 1 ]] ; then
	echo "Usage: $ generate_dataset.sh CONFIG_FILE_PATH"
	exit 1
fi

# Load config file
source $1


rearrange_data() {
	new_data_dir="./rearranged_data/"
	mkdir $new_data_dir

	for exp_dir in $(ls -d ${datasets_dir}/*/); do
		for svc_dir in $(ls -d ${exp_dir}*/); do
			svc_name=${svc_dir#*/}
			if [ ! -d "$new_data_dir$svc_name" ]; then
				mkdir -p "$new_data_dir$svc_name"
			fi
			mkdir $new_data_dir$svc_name$exp_dir
			cp -r $svc_dir* $new_data_dir$svc_name$exp_dir
		done
	done
}



case $BENCHMARK in
	
	TEA)
		teastore_load_generator $DURATION $STEP $WEBUI_ADDR "http://$PROMETHEUS_URL"
		;;
	TEA_TWO)
		teastore_double_load_generator $DURATION $STEP $WEBUI_ADDR "http://$PROMETHEUS_URL" $GENERATOR_ONE $GENERATOR_TWO
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
