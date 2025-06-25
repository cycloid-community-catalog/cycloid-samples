#! /usr/bin/env bash
set -eu

export CY_ORG=${CY_ORG:?org is required}
export CY_PROJECT=${CY_PROJECT:?project is required}
export CY_ENV=${CY_ENV:?environment is required}
export CY_COMPONENT=${CY_COMPONENT:?component is required}
export CY_COMPONENT_NAME=${CY_COMPONENT_NAME:?component name is required}
export CY_API_URL=${CY_API_URL:?cy api url is required}
export USE_CASE=${USE_CASE:?use case is required}
export CY_API_KEY=${CY_API_KEY:?api key is required}
export CY_STACKFORMS_VARS=${CY_STACKFORMS_VARS:?vars are needed}

echo "Started with the following config:"
echo "$CY_STACKFORMS_VARS"

echo "fetching required stacks..."
STACKS="$(cy stack list -o json)"
stack_network_ref="$(echo "$STACKS" | jq -r '.[] | select(.canonical == "network") | .ref')"
stack_database_ref="$(echo "$STACKS" | jq -r '.[] | select(.canonical == "database") | .ref')"
stack_caas_ref="$(echo "$STACKS" | jq -r '.[] | select(.canonical == "caas") | .ref')"
stack_sla_ref="$(echo "$STACKS" | jq -r '.[] | select(.canonical == "sla") | .ref')"

wait_for_component() {
  local component=${1:?component as first arg}

  echo "Starting build for ${component}"
  build_json="$(curl -s -X POST \
    "${CY_API_URL}/organizations/${CY_ORG}/projects/${CY_PROJECT}/environments/${CY_ENV}/components/${component}/pipelines/${CY_PROJECT}-${CY_ENV}-${component}/jobs/deploy/builds" \
    -H 'Accept: application/json' \
    -H "authorization: Bearer ${CY_API_KEY}" \
    -H 'content-type: application/vnd.cycloid.io.v1+json'
  )"

  sleep 5
  # build_id="$(echo "$build_json" | jq -r '.data.id')"
  echo "You can check deploy logs here:"
  echo "${CY_API_URL}/organizations/${CY_ORG}/projects/${CY_PROJECT}/environments/${CY_ENV}/components/${component}/pipelines/${CY_PROJECT}-${CY_ENV}-${component}/jobs/deploy/builds"

  count=0
  while true; do
    sleep 15
    status="$(curl -s \
      "${CY_API_URL}/organizations/${CY_ORG}/projects/${CY_PROJECT}/environments/${CY_ENV}/components/${component}/pipelines/${CY_PROJECT}-${CY_ENV}-${component}/jobs/deploy/builds" \
      -H 'Accept: application/json' \
      -H "Authorization: Bearer ${CY_API_KEY}" \
      -H 'content-type: application/vnd.cycloid.io.v1+json' \
    )"

    # status="$(echo "$status" | \
    #   jq -r --arg build_id "$build_id" \
    #   '.data.[] | select(.id == ($build_id | tonumber)) | .status' \
    # )"

    status=$(echo "$status" | jq -r .data[-1].status)

    (( count +=1 ))
    case "${status:-}" in
      "succeeded")
        break ;;
      "failed")
        echo "error: deployment of component ${component} failed, check logs and trigger again.";
        exit 1
        ;;
      *)
        echo "waiting for ${component} to deploy since: ${count} retry."
        continue ;;
    esac
  done
}

sla_component="sla"
sla_component_name="SLA"
cy component create --update \
  --component "$sla_component"  \
  --name "$sla_component_name" \
  --description "The SLA configuration managed by ${CY_COMPONENT_NAME}" \
  --stack-ref "$stack_sla_ref" --use-case "default" -o yaml

network_component="network"
network_component_name="Network"
cy component create --update \
  --component "$network_component"  \
  --name "$network_component_name" \
  --description "The network landing managed by ${CY_COMPONENT_NAME}" \
  --stack-ref "$stack_network_ref" --use-case "$USE_CASE" -o yaml

wait_for_component "$network_component"

database_component="database"
database_component_name="Database"
cy component create --update \
  --component "$database_component"  \
  --name "$database_component_name" \
  --description "The database managed by ${CY_COMPONENT_NAME}" \
  --stack-ref "$stack_database_ref" --use-case "$USE_CASE" -o yaml

wait_for_component "$database_component"

caas_component="caas"
caas_component_name="CAAS"
cy component create --update \
  --component "$caas_component"  \
  --name "$caas_component_name" \
  --description "The caas managed by ${CY_COMPONENT_NAME}" \
  --stack-ref "$stack_caas_ref" --use-case "$USE_CASE" -o yaml

wait_for_component "$caas_component"
