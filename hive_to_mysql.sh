#!/bin/bash
set -e

if [[ $# -lt 3 ]]; then
  echo "useage: hql, mysql_tbl, tbl_columns, data_date<optional>"
  exit 1
fi
