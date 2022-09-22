#!/bin/bash
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
    --external-url=*)
    API_URL="${i#*=}"
    shift
    ;;
    *) # unknown option
    ;;
esac
done

if [ -z $API_URL ]
then
    API_URL=https://sql.bytebase.com/v1/advise
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
    if [[ $FILE =~ \.sql$ ]]; then
        echo "Start check statement in file $FILE"
        $GITHUB_ACTION_PATH/sql-review.sh --file=$FILE --database-type=$DATABASE_TYPE --override="$override" --template-id="$TEMPLATE_ID" --api=$API_URL
        if [ $? != 0 ]; then
            result=1
        fi
    fi
done

exit $result
