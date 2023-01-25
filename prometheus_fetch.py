import requests

prometheus_url = 'http://172.16.52.8:30090'
query = 'kubelet_http_requests_total[24h]'
query2 = 'container_cpu_usage_seconds_total[24h]'


def query_prometheus(prometheus_url, query):
    url = prometheus_url + '/api/v1/query?query=' + query
    res = requests.get(url)
    print(res.json())
    
    return

query_prometheus(prometheus_url, query2)
