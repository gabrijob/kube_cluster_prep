import os
import requests
import argparse
from datetime import datetime, timedelta
import json
import urllib


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
    url = prometheus_url + '/api/v1/' + query
    #print("Querying " + url)
    try:
        res = requests.get(url).json()
    except:
        res = None
        print("...Fail at Prometheus request.")

    return res


def query_svc_names(prometheus_url):
    namespace = 'default'
    query_str = '/label/pod/values?match[]=kube_pod_container_info{namespace="' + namespace + '"}'
    #print("Querying existing services by " + query_str)
    res = query_prometheus(prometheus_url, query_str)
        
    svc_names = []
    services = []
    if res != None:
        svc_names = res['data']
        for name in svc_names:
            query_str = '/query?query=container_last_seen{namespace="' + namespace + '", pod="' + name + '"}'
            res = query_prometheus(prometheus_url, query_str)
            if res != None: 
                instance = res['data']['result'][0]['metric']['instance'].split(':')[0]
                node = res['data']['result'][0]['metric']['node']
                service_obj = {'pod': name, 'instance': instance, 'node': node}
                services.append(service_obj)
    
    #print("...Services found at namespace " + namespace + ': ' + str(services))
    return services


def fetch_svc_cadvisor_metrics(prometheus_url, svc, duration, datadir):
    h = {'Content-Type': 'application/x-www-form-urlencoded'}
    end_dt = datetime.now()
    start_dt = end_dt - timedelta(hours=float(duration))
    url = prometheus_url + '/api/v1/query_range?'
    
    # Query prometheus for each metric of given service
    for metric in cadvisor_metrics:
        payload = {'query': metric + '{pod="' + svc['pod'] + '"}', 'start': start_dt.timestamp(), 'end': end_dt.timestamp(), 'step': '15s'}
        #print("Querying " + url + " with payload " + str(payload))
        
        # Query Prometheus
        try:
            res = requests.post(url, headers=h, data=payload).json()
        except:
            res = None
            print("...Fail at Prometheus request.")

        # Save metrics to file
        if res != None:
            filename = datadir + '/' +metric + '_' + duration + '.json'
            with open(filename, 'w') as f:
                json.dump(res, f, ensure_ascii=False)
            #print("...Saved.")

    return


def fetch_svc_node_metrics(prometheus_url, svc, duration, datadir):
    h = {'Content-Type': 'application/x-www-form-urlencoded'}
    end_dt = datetime.now()
    start_dt = end_dt - timedelta(hours=float(duration))
    url = prometheus_url + '/api/v1/query_range?'

    # Query prometheus for each metric of given service
    for metric in node_metrics:
        payload = {'query': metric + '{instance="' + svc['instance'] + ':9100"}', 'start': start_dt.timestamp(), 'end': end_dt.timestamp(), 'step': '15s'}
        #print("Querying " + url + " with payload " + str(payload))
       
        # Query Prometheus
        try:
            res = requests.post(url, headers=h, data=payload).json()
        except:
            res = None
            print("...Fail at Prometheus request.")

        # Save metrics to file
        if res != None:
            filename = datadir + '/' +metric + '_' + duration + '.json'
            with open(filename, 'w') as f:
                json.dump(res, f, ensure_ascii=False)
            #print("...Saved.")

    return

def main():
    parser = argparse.ArgumentParser(description='Fetch Prometheus metrics to store it in JSON format.')
    parser.add_argument('prometheus_url', default='http://localhost:9090', help='URL of the Prometheus server')
    parser.add_argument('-t', '--time_duration', default='2', help='time duration in hours of observed time series')
    parser.add_argument('-n', '--name', default='dataset', help='name of the resulting dataset')
    args = parser.parse_args()

    services = query_svc_names(args.prometheus_url)
    dataset_dir = './data/' + args.name + '_' + datetime.now().strftime("%d-%m-%Y-%Hh%Mm%Ss")
    
    # Query all services for all metrics  
    for svc in services:
        svc_data_dir = dataset_dir + '/' + svc['pod']
        if not os.path.exists(svc_data_dir):
            os.makedirs(svc_data_dir)

        fetch_svc_cadvisor_metrics(args.prometheus_url, svc, args.time_duration, svc_data_dir)
        fetch_svc_node_metrics(args.prometheus_url, svc, args.time_duration, svc_data_dir)


if __name__ == "__main__":
    main()
