import os
import requests
import argparse
from datetime import datetime, timedelta
import json
import urllib
import configparser
import metrics

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


def query_svc_names(prometheus_url, namespace='default'):
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
            if res != None and len(res['data']['result']) > 0:
                instance = res['data']['result'][0]['metric']['instance'].split(':')[0]
                node = res['data']['result'][0]['metric']['node']
                service_obj = {'pod': name, 'instance': instance, 'node': node}
                services.append(service_obj)
    
    #print("...Services found at namespace " + namespace + ': ' + str(services))
    return services


def fetch_all_metrics(metrics, prometheus_url, svc, duration, step, datadir):
    end_dt = datetime.now()
    start_dt = end_dt - timedelta(hours=float(duration))

    for metric in metrics:
        metric.query(prometheus_url, svc, start_dt, end_dt, step, datadir)


def init_all_metrics(metric_config_file='metrics.ini', prometheus_url="http://localhost:9090"):
    metric_config = configparser.ConfigParser()
    metric_config.read(metric_config_file)
   
    # Read all cAdvisor metrics from config file 
    cadvisor_metrics = []
    for item in metric_config.items('CADVISOR'):
        cadvisor_metrics.extend([name.strip() for name in item[1].split(',')])
    # Read all NodeExporter metrics from config file 
    node_metrics = []
    for item in metric_config.items('NODE'):
        node_metrics.extend([name.strip() for name in item[1].split(',')])
    
    all_metrics = []
    # Generate PrometheusMetricList for cadvisorMetric objects
    all_metrics.append( metrics.PrometheusMetricList(cadvisor_metrics, metrics.cadvisorMetric, prometheus_url) )
    # Generate PrometheusMetricList for nodeMetric objects
    all_metrics.append( metrics.PrometheusMetricList(node_metrics, metrics.nodeMetric, prometheus_url) )

    return all_metrics


def main():
    parser = argparse.ArgumentParser(description='Fetch Prometheus metrics to store it in JSON format.')
    parser.add_argument('prometheus_url', default='http://localhost:9090', help='URL of the Prometheus server')
    parser.add_argument('-t', '--time_duration', default='2', help='time duration in hours of observed time series')
    parser.add_argument('-s', '--time_step', default='1', help='time step in seconds of observed time series')
    parser.add_argument('-N', '--name', default='dataset', help='name of the resulting dataset')
    parser.add_argument('-n', '--namespace', default='default', help='kubernetes namespace of observed application')
    parser.add_argument('-c', '--config', default='metrics.ini', help='path to .ini file with metrics names')
    args = parser.parse_args()

    services = query_svc_names(args.prometheus_url, namespace=args.namespace)
    dataset_dir = './data/' + args.name + '_' + datetime.now().strftime("%d-%m-%Y-%Hh%Mm%Ss")

    all_metrics = init_all_metrics(args.config, args.prometheus_url)

    # Query all services for all metrics  
    for svc in services:
        svc_data_dir = dataset_dir + '/' + svc['pod']
        if not os.path.exists(svc_data_dir):
            os.makedirs(svc_data_dir)
    
            end_dt = datetime.now()
            start_dt = end_dt - timedelta(hours=float(args.time_duration))
            for metric_list in all_metrics:
                metric_list.query_for_service(svc, start_dt, end_dt, args.time_step, svc_data_dir)


if __name__ == "__main__":
    main()
