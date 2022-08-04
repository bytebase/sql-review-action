#!/bin/sh
# ===========================================================================
# File: main.sh
# Description: usage: ./main.sh --files=[files] --database-type=[database type] --override-file=[override file path] --template-id=[template id]
# ===========================================================================

# Get parameters
for i in "$@"
do
case $i in
    --files=*)
    FILES="${i#*=}"
    shift
    ;;
    --database-type=*)
    DATABASE_TYPE="${i#*=}"
    shift
    ;;
    --override-file=*)
    OVERRIDE_FILE="${i#*=}"
    shift
    ;;
    --template-id=*)
    TEMPLATE_ID="${i#*=}"
    shift
    ;;
    *) # unknown option
    ;;
esac
done

DOC_URL=https://www.bytebase.com/docs/reference/error-code/advisor
API_URL=$BB_SQL_API
if [ -z $API_URL ]
then
    API_URL=https://bytebase-sql-service.onrender.com/v1/sql/advise
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
    # The action tj-actions/changed-files has a bug. When no files match the pattern, it will return all changed files
    if [[ $FILE =~ \.sql$ ]]; then
        echo "Start check statement in file $FILE"
        ./sql-review.sh --file=$FILE --database-type=$DATABASE_TYPE --override="$override" --template-id="$TEMPLATE_ID" --api=$API_URL
        if [ $? != 0 ]; then
            result=1
        fi
    fi
done

exit $result
