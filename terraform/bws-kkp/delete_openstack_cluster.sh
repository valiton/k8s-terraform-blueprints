#!/bin/bash

KKP_API_URL="$1"
PROJECT_ID="$2"
KKP_TOKEN="$3"

CLUSTER_ID=$(cat .cluster_id)

echo "🔄 Deleting cluster: $CLUSTER_ID..."

curl -s -X DELETE "$KKP_API_URL/api/v2/projects/$PROJECT_ID/clusters/$CLUSTER_ID" \
	-H "Authorization: Bearer $KKP_TOKEN" \
	-H "Content-Type: application/json"

echo "⏳ Waiting for cluster deletion..."
for i in {1..60}; do
	sleep 10
	STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
		"$KKP_API_URL/api/v2/projects/$PROJECT_ID/clusters/$CLUSTER_ID" \
		-H "Authorization: Bearer $KKP_TOKEN")

	if [ "$STATUS" = "404" ]; then
		echo "✅ Cluster deleted."
		rm -f .cluster_id
		exit 0
	fi
done

echo "❌ Timeout waiting for deletion."
exit 1
