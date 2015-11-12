#!/bin/bash
set -e

PWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $PWD/../functions.sh
source_bashrc

for i in $(ls $PWD/*.sql | grep -v report.sql); do
	table_name=`echo $i | awk -F '.' '{print $3}'`
	LOCATION="'gpfdist://$HOSTNAME:$GPFDIST_PORT/log/rollout_$table_name.log'"

	echo "psql -h $MASTER_HOST -v ON_ERROR_STOP=1 -a -f $i -v LOCATION=\"$LOCATION\""
	psql -h $MASTER_HOST -v ON_ERROR_STOP=1 -a -f $i -v LOCATION="$LOCATION"
	echo ""
done

start_gpfdist

psql -h $MASTER_HOST -P pager=off -f $PWD/detailed_report.sql
echo ""
psql -h $MASTER_HOST -P pager=off -f $PWD/summary_report.sql


stop_gpfdist
