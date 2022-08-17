#!/bin/bash
# ===========================================================================
# File: sql-review.sh
# Description: usage: ./sql-review.sh --file=[file] --database-type=[database type] --override=[override] --template-id=[template id] --api=[API URL]
# ===========================================================================

# Get parameters
for i in "$@"
do
case $i in
    --file=*)
    FILE="${i#*=}"
    shift
    ;;
    --database-type=*)
    DATABASE_TYPE="${i#*=}"
    shift
    ;;
    --override=*)
    OVERRIDE="${i#*=}"
    shift
    ;;
    --template-id=*)
    TEMPLATE_ID="${i#*=}"
    shift
    ;;
    --api=*)
    API_URL="${i#*=}"
    shift
    ;;
    *) # unknown option
    ;;
esac
done

DOC_URL=https://www.bytebase.com/docs/reference/error-code/advisor

statement=`cat $FILE`
if [ $? != 0 ]; then
    echo "::error::Cannot open file $FILE"
    exit 1
fi

version=`cat $GITHUB_ACTION_PATH/VERSION`
actor=`echo $GITHUB_ACTOR | tr '[:upper:]' '[:lower:]'`
repository=`echo $GITHUB_REPOSITORY | tr '[:upper:]' '[:lower:]'`

request_body=$(jq -n \
    --arg statement "$statement" \
    --arg override "$OVERRIDE" \
    --arg databaseType "$DATABASE_TYPE" \
    --arg templateId "$TEMPLATE_ID" \
    '$ARGS.named')
response=$(curl -s -w "%{http_code}" -X POST $API_URL \
  -H "X-Platform: GitHub" \
  -H "X-Repository: $repository" \
  -H "X-Actor: $actor" \
  -H "X-Version: $version" \
  -H "X-Source: action" \
  -H "Content-Type: application/json" \
  -d "$request_body")
http_code=$(tail -n1 <<< "$response")
body=$(sed '$ d' <<< "$response")

echo "::debug::response code: $http_code, response body: $body"

if [ $http_code != 200 ]; then
    echo ":error::Failed to check SQL with response code $http_code and body $body"
    exit 1
fi

result=0
index=0

while read code; do
    content=`echo $body | jq -r ".[$index].content"`
    status=`echo $body | jq -r ".[$index].status"`
    title=`echo $body | jq -r ".[$index].title"`
    (( index++ ))

    echo "::debug::status:$status, code:$code, title:$title, content:$content"

    if [ -z "$content" ]; then
        # The content cannot be empty. Otherwise action cannot output the error message in files.
        content=$title
    fi

    if [ $code != 0 ]; then
        title="$title ($code)"
        # To indent the output message
        content="$content
Doc: $DOC_URL#$code"

        echo "### [$status] $title" >> $GITHUB_STEP_SUMMARY
        echo "$content" >> $GITHUB_STEP_SUMMARY

        content="${content//$'\n'/'%0A'}"
        error_msg="file=$FILE,line=1,col=1,endColumn=2,title=$title::$content"

        if [ $status == 'WARN' ]; then
            echo "::warning $error_msg"
        else
            result=$code
            echo "::error $error_msg"
        fi
    fi
done <<< "$(echo $body | jq -r '.[]' | jq '.code')"

exit $result
