#!/usr/bin/env python3
from json.tool import main
import os, sys, json, requests

ENDPOINT="http://10.10.2.13:3000"

def load_dashboard(path, substitute=False):
    if substitute:
        with open(path) as src:
            # raw = host_replace(src.read())
            raw = src.read()
            return json.loads(raw)
    else:
        return json.load(open(path))

def post(path, payload={}):
    return requests.post(
        "%s/api/%s" % (ENDPOINT, path),
        auth=requests.auth.HTTPBasicAuth("admin", "admin"),
        headers={'Content-Type': 'application/json'},
        json=payload
    ).json()

def add_dashboard(d, folder=None):
    """put raw dashboard"""
    d["id"] = None

    payload = {"dashboard": d, "overwrite": True} 
    if folder is not None and folder != "":
        payload["folderUid"] = folder
    else:
        payload["folderId"] = 0
    return post('dashboards/db', payload)

def init_all(dashboard_dir):
    folders = []
    
    for f in os.listdir(dashboard_dir):
        abs_path = os.path.join(dashboard_dir, f)
        if os.path.isfile(abs_path) and f.endswith('.json'):
            print("init dashboard : %s" % f)
            add_dashboard(load_dashboard(abs_path, True))
        if os.path.isdir(abs_path):
            folders.append((f, abs_path))  # folder name, abs path

if __name__ == '__main__':
    print("starting ")
    dashboard_dir= "grafana-zhj-uucin-com"
    init_all(dashboard_dir)
    print("done ")