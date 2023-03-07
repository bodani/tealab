Grafana API


# Get Organization
curl -u 'admin:admin' -H 'Content-Type: application/json'  -X GET   http://127.0.0.1:3000/api/org/
# {"id":1,"name":"Main Org.","address":{"address1":"","address2":"","city":"","zipCode":"","state":"","country":""}}

# Update Organization Name
curl -u 'admin:admin' -H 'Content-Type: application/json'  -X PUT   http://127.0.0.1:3000/api/orgs/1    -d '{"name": "tea"}'
# {"message":"Organization updated"}

# Search Dashboard by Name
curl -u 'admin:admin' -H 'Content-Type: application/json'  -X GET   http://127.0.0.1:3000/api/dashboards/uid/home
GRAFANA_HOME_ID=$(curl -u 'admin:admin' -H 'Content-Type: application/json' -sSL -X GET   http://127.0.0.1:3000/api/dashboards/uid/home | jq '.dashboard.id')

# Star the home dashboard 
curl -u 'admin:admin' -H 'Content-Type: application/json'  -X POST  "http://127.0.0.1:3000/api/user/stars/dashboard/${GRAFANA_HOME_ID}"

# Update preference
GRAFANA_PREF='{"theme":"light","homeDashboardId":'${GRAFANA_HOME_ID}'}'
curl -u 'admin:admin' -H 'Content-Type: application/json'  -X PUT "http://127.0.0.1:3000/api/org/preferences" -d ${GRAFANA_PREF}
curl -u 'admin:admin' -H 'Content-Type: application/json'  -X PUT "http://127.0.0.1:3000/api/user/preferences" -d ${GRAFANA_PREF}

# Create folder pgsql pglog pgcat
curl -u 'admin:admin' -H 'Content-Type: application/json'  -X POST  "http://127.0.0.1:3000/api/folders/" -d '{"uid": "pgsql", "title": "PGSQL"}'
curl -u 'admin:admin' -H 'Content-Type: application/json'  -X POST  "http://127.0.0.1:3000/api/folders/" -d '{"uid": "pglog", "title": "PGLOG"}'
curl -u 'admin:admin' -H 'Content-Type: application/json'  -X POST  "http://127.0.0.1:3000/api/folders/" -d '{"uid": "pgcat", "title": "PGCAT"}'

# Create folder 
curl -u 'admin:admin' -H 'Content-Type: application/json'  -X POST  "http://127.0.0.1:3000/api/folders/" -d '{"uid": "pgsql", "title": "PGSQL"}'


# 安装包下载地址
# https://prometheus.io/download/