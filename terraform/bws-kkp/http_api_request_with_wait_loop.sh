#!/bin/bash

## Variables must be set in environment.
## When MATCH_RESPONSE_JSON_FIELD_SELECTOR is not set or empty, that check will be skipped.

## Set default values when variables are not set or empty.
DEBUG=${DEBUG:-"0"}
TIMEOUT_SECONDS=${TIMEOUT_SECONDS:-600}
MATCH_HTTP_STATUS_CODE=${MATCH_HTTP_STATUS_CODE:-200}

if [[ "$DEBUG" = "1" ]]; then
  DEBUG_LOG_FILE=".http_api_request_with_wait_loop_debug.log"
  echo "" >> $DEBUG_LOG_FILE
  echo "API_URL=$API_URL" >> $DEBUG_LOG_FILE
  echo "API_TOKEN=$API_TOKEN" >> $DEBUG_LOG_FILE
  echo "MATCH_HTTP_STATUS_CODE=$MATCH_HTTP_STATUS_CODE" >> $DEBUG_LOG_FILE
  echo "MATCH_RESPONSE_JSON_FIELD_SELECTOR=$MATCH_RESPONSE_JSON_FIELD_SELECTOR" >> $DEBUG_LOG_FILE
  echo "MATCH_RESPONSE_JSON_FIELD_VALUE=$MATCH_RESPONSE_JSON_FIELD_VALUE" >> $DEBUG_LOG_FILE
  echo "TIMEOUT_SECONDS=$TIMEOUT_SECONDS" >> $DEBUG_LOG_FILE
fi

loop_iteration_sleep_seconds=10
loop_iterations=$(awk "BEGIN {print int($TIMEOUT_SECONDS / $loop_iteration_sleep_seconds) + ($TIMEOUT_SECONDS % $loop_iteration_sleep_seconds > 0 ? 1 : 0)}")

echo "⏳ Waiting ..."
for ((i=1; i<=loop_iterations; i++)); do
  sleep $loop_iteration_sleep_seconds

  response_json=$(curl -s -L \
    "$API_URL" \
    -w "%output{.http_api_request_with_wait_loop_last_http_status_code.txt}%{response_code}" \
    -H "Authorization: Bearer $API_TOKEN"
  )

  if [[ "$DEBUG" = "1" ]]; then
    http_status_code=$(cat .http_api_request_with_wait_loop_last_http_status_code.txt)
    echo "http_status_code: $http_status_code; response_json: $response_json" >> $DEBUG_LOG_FILE
  fi
  rm .http_api_request_with_wait_loop_last_http_status_code.txt

  if [[ "$http_status_code" = "$MATCH_HTTP_STATUS_CODE" ]]; then
    actionIsFinished=0
    if [[ "$MATCH_RESPONSE_JSON_FIELD_SELECTOR" = "" ]]; then
      actionIsFinished=1
    else
      field_value=$(echo "$response_json" | jq -r "$MATCH_RESPONSE_JSON_FIELD_SELECTOR")
      jq_exit_status=$?

      field_value=$(echo "$field_value" | tr -d '\n') # Remove newline characters.

      if [[ $jq_exit_status -eq 0 ]] && [[ "$field_value" = "$MATCH_RESPONSE_JSON_FIELD_VALUE" ]]; then
        actionIsFinished=1
      fi
    fi

    if [[ $actionIsFinished -eq 1 ]]; then
      echo "✅ Finished."
      exit 0
    fi
  fi
done

echo "❌ Timeout."
exit 1
