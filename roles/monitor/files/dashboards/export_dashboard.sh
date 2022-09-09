#!/bin/bash

# Usage:
# username admin
# password REDACTED
# export_grafana_dashboards.sh https://admin:REDACTED@grafana.xxxx.com

create_slug () {
  echo "$1" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z
}

full_url=$1
# username=$(echo "${full_url}" | cut -d/ -f 3 | cut -d: -f 1)
base_url=$(echo "${full_url}" | cut -d@ -f 2)
folder=$(create_slug "${base_url}")

mkdir "${folder}"
for db_uid in $(curl -s "${full_url}/api/search" | jq -r .[].uid); do
  echo "start export dashboard. db_uid ${db_uid}"
  db_json=$(curl -s "${full_url}/api/dashboards/uid/${db_uid}")
  db_slug=$(echo "${db_json}" | jq -r .meta.slug)
  db_title=$(echo "${db_json}" | jq -r .dashboard.title)
  filename="${folder}/${db_slug}.json"
  echo "Exporting \"${db_title}\" to \"${filename}\"..."
  echo "${db_json}" | jq -r . > "${filename}"
done
echo "Done"