#!/bin/sh
# ===========================================================================
# File: sql-review.sh
# Description: usage: ./sql-review.sh [files] [database type] [override file path] [template id]
# ===========================================================================

FILES=$1
DATABASE_TYPE=$2
OVERRIDE_FILE=$3
TEMPLATE_ID=$4

DOC_URL=https://www.bytebase.com/docs/reference/error-code/advisor
API_URL=$BB_SQL_API
if [ -z $API_URL ]
then
    API_URL=https://sql-service.onrender.com/v1/sql/advise
fi

override=""
if [ ! -z $OVERRIDE_FILE ]
then
    override=`cat $OVERRIDE_FILE`

    if [ $? != 0 ]
    then
        echo "::error file=$FILE,line=1,col=5,endColumn=7::Cannot find SQL review config file"
        exit 1
    fi
fi

result=0
for FILE in $FILES; do
    echo "Start check statement in file $FILE"
    ./check-statement.sh $FILE $DATABASE_TYPE "$override" "$TEMPLATE_ID" $API_URL
    if [ $? != 0 ]; then
        result=1
    fi
done

exit $result
