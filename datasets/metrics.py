import os
import requests
from datetime import datetime, timedelta
import json
import urllib


class Metric:
    def __init__(self, name, form, unit, query_modifier=lambda s:s):
        self.name = name
        self.form = form
        self.unit = unit
        self.query_modifier = query_modifier

    def _query_str(self, svc):
        return self.query_modifier(self.name)

    def query_for_service(self, prometheus_url, svc, start_dt, end_dt, step, datadir):
        query_str = self._query_str(svc)
        payload = {'query': query_str, 'start': start_dt.timestamp(), 'end': end_dt.timestamp(), 'step': step+'s'}

        url = prometheus_url + '/api/v1/query_range?'
        print("Querying " + url + " with payload " + str(payload))
       
        # Query Prometheus
        try:
            res = requests.post(url, headers={'Content-Type': 'application/x-www-form-urlencoded'}, data=payload).json()
        except:
            res = None
            print("...Fail at Prometheus request.")

        if res != None and len(res['data']['result']) > 0:
            self._save_as_json(res, datadir)

        return res

    def _save_as_json(self, res, datadir):
        # Save metrics to file
        filename = datadir + '/' + self.name + '.json'
        with open(filename, 'w') as f:
            json.dump(res, f, ensure_ascii=False)
        #print("...Saved.")


class PrometheusMetricList():
    def __init__(self, metric_names, metric_class=Metric, url="http://localhost:9090"):
        self.names = metric_names
        self.metric_objs = []
        self.metric_class = metric_class
        
        self.url = url
        self._init_metric_metadata()

    def _get_query_modifier(self, metadata):
        if (metadata['type'] == "gauge"):
            modifier = lambda s: 'sum(' + s + ')'
        elif (metadata['type'] == "counter"):
            modifier = lambda s: 'sum(rate(' + s + '[30s]))'  
        else:
            modifier = lambda s: s

        return modifier

    def _init_metric_metadata(self):
        for metric in self.names:
            query_str = 'metadata?metric=' + metric
            url = self.url + '/api/v1/' + query_str
            #print("Querying " + url)
            try:
                res = requests.get(url).json()
            except:
                res = None
                print("...Fail at Prometheus request.")

            if res != None:
                metadata = res['data'][metric][0]

            metric_obj = self.metric_class(name=metric, \
                    form=metadata['type'], \
                    unit=metadata['unit'], \
                    query_modifier=self._get_query_modifier(metadata))
            
            self.metric_objs.append(metric_obj)
      
    def query_for_service(self, service, start_dt, end_dt, step, datadir):
        for metric in self.metric_objs:
            metric.query_for_service(self.url, service, start_dt, end_dt, step, datadir)


class cadvisorMetric(Metric):
    def _query_str(self, svc):
        return self.query_modifier(self.name + '{pod="' + svc['pod'] + '"}')


class nodeMetric(Metric):
    def _query_str(self, svc):
        return self.query_modifier(self.name + '{instance="' + svc['instance'] + ':9100"}')











