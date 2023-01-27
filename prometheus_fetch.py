import os
import requests
import argparse
from datetime import datetime
import json


prometheus_url = 'http://172.16.52.8:30090'
query = 'kubelet_http_requests_total[24h]'
query2 = 'container_cpu_usage_seconds_total[24h]'

cadvisor_metrics = ['container_cpu_usage_seconds_total', 'container_network_receive_packets_total', 
                    'container_network_receive_packets_dropped_total', 'container_memory_failures_total', 
                    'container_memory_cache']

node_metrics = ['node_memory_MemTotal_bytes', 'node_memory_MemFree_bytes', 'node_cpu_frequency_max_hertz',
                'node_cpu_frequency_min_hertz', 'node_disk_io_now', 'node_disk_io_time_seconds_total']


# | One directory per experiment 
# |- One directory per service
# |-- One file per metric 

def query_prometheus(prometheus_url, query):
    url = prometheus_url + '/api/v1/query?query=' + query
    try:
        res = requests.get(url).json()
    except:
        res = None
        print("...Fail at Prometheus request.")

    return res


def fetch_svc_cadvisor_metrics(prometheus_url, svc_name, duration):
    # query prometheus for each metric of given service
    for metric in cadvisor_metrics:
        query_str = metric + '[' + duration + ']'
        print("Querying " + query_str)
        res = query_prometheus(prometheus_url, query_str)

        if res != None:
            # store metrics in proper file
            filename = metric + '_' + duration + '.json'
            with open(filename, 'w') as f:
                json.dump(res, f, ensure_ascii=False)
            print("...Saved.")

    return


def fetch_svc_node_metrics(prometheus_url, svc_name, duration):
    # query prometheus for each metric of given service
    for metric in node_metrics:
        query_str = metric + '[' + duration + ']'
        print("Querying " + query_str)
        res = query_prometheus(prometheus_url, query_str)

        if res != None:
            # store metrics in proper file
            filename = metric + '_' + duration + '.json'
            with open(filename, 'w') as f:
                json.dump(res, f, ensure_ascii=False)
            print("...Saved.")

    return


def query_svc_names(prometheus_url):
    svc_names = ['teastore']
    return svc_names

#TODO: test to know the exact format of needed requests and how to extract the wanted metrics from the json response 
def main():
    parser = argparse.ArgumentParser(description='Fetch Prometheus metrics to store it in JSON format.')
    parser.add_argument('prometheus_url', default='http://localhost:9090', help='URL of the Prometheus server')
    parser.add_argument('-t', '--time_duration', default='24h', help='time duration of observed metric')
    parser.add_argument('-n', '--name', default='dataset', help='name of the resulting dataset')
    args = parser.parse_args()

    svc_names = query_svc_names(args.prometheus_url)
    dataset_dir = './data/' + args.name + '_' + datetime.now().strftime("%d-%m-%Y-%Hh%Mm%Ss")
    
    # Query all services for all metrics  
    for svc in svc_names:
        svc_data_dir = dataset_dir + '/' + svc
        if not os.path.exists(svc_data_dir):
            os.makedirs(svc_data_dir)

        fetch_svc_cadvisor_metrics(args.prometheus_url, svc, args.time_duration)
        fetch_svc_node_metrics(args.prometheus_url, svc, args.time_duration)


if __name__ == "__main__":
    main()