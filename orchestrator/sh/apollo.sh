#!/usr/bin/env bash
# apollo.sh — enrich contacts and search leads via Apollo.io REST API
# Docs: https://apolloio.github.io/apollo-api-docs/
# Endpoint: https://api.apollo.io/api/v1
# Actions: enrich, search
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: apollo $(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','enrich'))")" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','enrich'))")"
echo "INFO: apollo action=$ACTION" >&2

BASE_URL="https://api.apollo.io/api/v1"

case "$ACTION" in
  enrich)
    EMAIL="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('email',''))")"
    DOMAIN="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('domain',''))")"

    BODY="$(python3 -c "
import json
d = {}
email = '''$EMAIL'''
domain = '''$DOMAIN'''
if email:
    d['email'] = email
if domain:
    d['domain'] = domain
print(json.dumps(d))
")"

    HTTP_STATUS=$(curl -s -o /tmp/apollo_response.json -w "%{http_code}" \
      -X POST \
      -H "Content-Type: application/json" \
      -H "Cache-Control: no-cache" \
      -H "X-Api-Key: ${APOLLO_API_KEY:?APOLLO_API_KEY is required}" \
      -d "$BODY" \
      "${BASE_URL}/people/match")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" ]]; then
      echo "ERROR: Apollo API returned HTTP $HTTP_STATUS" >&2
      cat /tmp/apollo_response.json >&2
      exit 1
    fi

    cat /tmp/apollo_response.json
    echo "INFO: apollo enrich succeeded (HTTP $HTTP_STATUS)" >&2
    ;;

  search)
    QUERY="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('query',{})))")"

    BODY="$(python3 -c "
import json
print(json.dumps(json.loads('''$QUERY''')))
")"

    HTTP_STATUS=$(curl -s -o /tmp/apollo_response.json -w "%{http_code}" \
      -X POST \
      -H "Content-Type: application/json" \
      -H "Cache-Control: no-cache" \
      -H "X-Api-Key: ${APOLLO_API_KEY:?APOLLO_API_KEY is required}" \
      -d "$BODY" \
      "${BASE_URL}/mixed_people/search")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" ]]; then
      echo "ERROR: Apollo API returned HTTP $HTTP_STATUS" >&2
      cat /tmp/apollo_response.json >&2
      exit 1
    fi

    cat /tmp/apollo_response.json
    echo "INFO: apollo search succeeded (HTTP $HTTP_STATUS)" >&2
    ;;

  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
