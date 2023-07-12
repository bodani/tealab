#!/usr/bin/env bash
set -Eeu 

#/etc/patroni/setup_cluster.sh', 'dbname=postgres user=postgres port=5432'#
psql "$1" -f /etc/patroni/setup_cluster.sql