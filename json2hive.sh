#!/bin/bash
set -e
if [[ $# -lt 3 ]]; then
  echo "usage: json2hive.sh url tbl app"
  exit 1
fi

url=$1
tbl=$2
app=$3

echo -e "`date` \n url: $url, tbl: $tbl app: $app"

date=""
file=""

if [[ $url == http* ]]; then
  echo "http resources"
  date=`echo $url | rev | cut -d'/' -f1 | rev | grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}"`
else
  echo "file resources"
  date = `echo $url |  grep -Eo "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}"`
fi
file=`echo $url | rev | cut -d'/' -f1 | rev"

if [[ -z $date ]]; then
  date=`date +%Y-%m-%d`
  echo "no date found from url, make it as today: $date"
fi

file="${app}_${file}"

hive_home=""
work_dir=""
tmp_dir="$work_dir/tmp"
cd $work_dir

[[ ! -f $tmp_dir ]] && mkdir -p $tmp_dir
csv_file_path = "$tmp_dir/$file"
rm -rf $csv_file_path

export PYTHON_VERSION=2.7
export PYTHONLOCALIZED=~/python$PYTHON_VERSION
export PYTHONUSERBASE=$PYTHONLOCALIZED
export PYTHONPATH=$PYTHONLOCALIZED/lib:$PYTHONLOCALIZED/lib/python$PYTHON_VERSION

./json2csv.py $url $csv_file_path
echo "json2csv done"

line_cnt=`wc -l $csv_file_path"
sed -i 's/,/\x01/g' $csv_file_path


pt="'"$date"'"
local_path="'"$csv_file_path"'"
$hive_home/bin/hive -e "alter table $tbl drop if exists partition(pt=$pt)"
$hive_home/bin/hive -e "load data local inpath $local_path into table $tbl partition (pt=$pt)"

cnt=`hive -e "select count(*) from $tbl where pt=$pt"`
if [[ $cnt -lt 1 ]]; then
  echo "no rec in hive"
  exit 1
else 
  echo "rec cnt: $cnt"
fi
echo "done `date`"





