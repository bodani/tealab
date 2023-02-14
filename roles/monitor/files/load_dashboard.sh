#!/bin/bash

# grafana access info
export GRAFANA_ENDPOINT="http://127.0.0.1:3000"
export GRAFANA_USERNAME={{ grafana_admin_username }}
export GRAFANA_PASSWORD={{ grafana_admin_password }}

# run provisinoing logic
python /var/lib/grafana/grafana.py init /var/lib/grafana/dashboards