#!/bin/bash
set -uo pipefail

psql -Atqwc 'CHECKPOINT;CHECKPOINT;'