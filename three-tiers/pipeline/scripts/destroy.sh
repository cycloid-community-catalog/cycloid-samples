#! /usr/bin/env bash
set -eu

export CY_ORG=${CY_ORG:?org is required}
export CY_PROJECT=${CY_PROJECT:?project is required}
export CY_ENV=${CY_ENV:?environment is required}
export CY_COMPONENT=${CY_COMPONENT:?component is required}
export CY_COMPONENT_NAME=${CY_COMPONENT_NAME:?component name is required}
export CY_API_URL=${CY_API_URL:?cy api url is required}
export CY_API_KEY=${CY_API_KEY:?api key is required}

destroy_component() {
  local component="${1:?component as first arg}"
  local name="${2:?component name as second arg}"

  echo "Starting destruction for ${name}"
  build_json="$(curl -s -X POST \
    "${CY_API_URL}/organizations/${CY_ORG}/projects/${CY_PROJECT}/environments/${CY_ENV}/components/${CY_COMPONENT}/pipelines/${CY_PROJECT}-${CY_ENV}-${component}/jobs/destroy/builds" \
    -H 'Accept: application/json' \
    -H "authorization: Bearer ${CY_API_KEY}" \
    -H 'content-type: application/vnd.cycloid.io.v1+json'
  )"

  # build_id="$(echo "$build_json" | jq -r '.data.id')"
  sleep 5

  count=0
  while true; do
    sleep 15
    status="$(curl -s \
      "${CY_API_URL}/organizations/${CY_ORG}/projects/${CY_PROJECT}/environments/${CY_ENV}/components/${component}/pipelines/${CY_PROJECT}-${CY_ENV}-${component}/jobs/destroy/builds" \
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
        echo "error: destruction of component ${component} failed, check logs and trigger again.";
        exit 1
        ;;
      *)
        echo "waiting for ${component} to destroy since: ${count} retry."
        continue ;;
    esac
  done

  echo "Deleting cycloid component ${component}"
  cy component delete --component "${component}"
}

# Reverse the order of the components
caas_component="${CY_COMPONENT}-caas"
caas_component_name="${CY_COMPONENT_NAME}: CAAS"
destroy_component "$caas_component" "$caas_component_name"

database_component="${CY_COMPONENT}-database"
database_component_name="${CY_COMPONENT_NAME}: Postgres"
destroy_component "$database_component" "$database_component_name"

network_component="${CY_COMPONENT}-network"
network_component_name="${CY_COMPONENT_NAME}: Network"
destroy_component "$network_component" "$network_component_name"
