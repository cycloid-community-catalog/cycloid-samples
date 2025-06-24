#! /usr/bin/env bash
set -eu

export CY_ORG=digit
export CY_PROJECT=playground
export CY_ENV=azure
export CY_COMPONENT=management
export CY_COMPONENT_NAME=Management
export CY_API_URL=https://api.digit.cycloid.io/
export USE_CASE="azure"
CY_API_KEY="$(op read "op://Cycloid/API_saas_eu_digit/identifiant")"
export CY_API_KEY

CY_STACKFORMS_VAR=$(cat <<EOF |
---
aws:
  Configurations:
    Access:
      aws_default_region: ((aws_default_region))
      network_inventory: ((network_inventory))
    Database:
      postgres_engine_version: ((postgres_engine_version))
      postgres_type: ((postgres_type))
      postgres_backup_retention: ((postgres_backup_retention))
    Infrastructure:
      database_inventory: # arn ?
      demo_gitlab_project: ((demo_gitlab_project))
      web_image_version: ((web_image_version))

azure:
  "Cloud provider":
    Settings:
      location: "West Europe"
  Database:
    Settings:
      virtual_network_name: "main-network"
      sku: "bCU1"
      # backup_retention_days: 7
      user: petclinic
      database: petclinic
      engine_version: "16"
      resource_group_name: ${CY_PROJECT}-${CY_ENV}-${CY_COMPONENT}
  Configuration:
    Infrastructure:
      db_name: "postgres-${CY_PROJECT}-${CY_ENV}"
    Application:
      demo_gitlab_project: ((demo_gitlab_project))
      web_image_version: ((web_image_version))
EOF
yq -r ".${USE_CASE}"
)$

echo "Started with the following config:"
echo "$CY_STACKFORMS_VAR"

STACKS="$(cy stack list -o json)"
stack_network_ref="$(echo "$STACKS" | jq -r '.[] | select(.canonical == "network") | .ref')"
stack_database_ref="$(echo "$STACKS" | jq -r '.[] | select(.canonical == "database") | .ref')"
stack_caas_ref="$(echo "$STACKS" | jq -r '.[] | select(.canonical == "caas") | .ref')"

export CY_STACKFORMS_VAR
wait_for_component() {
  local component=${1:?component as first arg}

  echo "Starting build for ${component}"
  build_json="$(curl -s -X POST \
    "${CY_API_URL}/organizations/${CY_ORG}/projects/${CY_PROJECT}/environments/${CY_ENV}/components/${CY_COMPONENT}/pipelines/${CY_PROJECT}-${CY_ENV}-${component}/jobs/deploy/builds" \
    -H 'Accept: application/json' \
    -H "authorization: Bearer ${CY_API_KEY}" \
    -H 'content-type: application/vnd.cycloid.io.v1+json'
  )"

  build_id="$(echo "$build_json" | jq -r '.data.id')"
  echo "You can check deploy logs here:"
  echo "${CY_API_URL}/organizations/${CY_ORG}/projects/${CY_PROJECT}/environments/${CY_ENV}/components/${component}/pipelines/${CY_PROJECT}-${CY_ENV}-${component}/jobs/deploy/builds/${build_id}#overview"

  count=0
  while true; do
    sleep 1
    status="$(curl -s \
      "${CY_API_URL}/organizations/${CY_ORG}/projects/${CY_PROJECT}/environments/${CY_ENV}/components/${component}/pipelines/${CY_PROJECT}-${CY_ENV}-${component}/jobs/deploy/builds" \
      -H 'Accept: application/json' \
      -H "Authorization: Bearer ${CY_API_KEY}" \
      -H 'content-type: application/vnd.cycloid.io.v1+json' \
    )"

    status="$(echo "$status" | \
      jq -r --arg build_id "$build_id" \
      '.data.[] | select(.id == ($build_id | tonumber)) | .status' \
    )"

    (( count +=1 ))
    case "${status:-}" in
      "succeeded")
        break ;;
      "failed")
        echo "error: deployment of component ${component} failed, check logs and trigger again.";
        exit 1
        ;;
      *)
        echo "waiting for ${component} to deploy since: ${count} seconds."
        continue ;;
    esac
  done
}

# set -x
network_component="${CY_COMPONENT}-network"
network_component_name="${CY_COMPONENT_NAME}: Network"
cy component create --update \
  --component "$network_component"  \
  --name "$network_component_name" \
  --description "The network landing zone for ${CY_COMPONENT_NAME}" \
  --stack-ref "$stack_network_ref" --use-case "$USE_CASE" -o yaml
wait_for_component "$network_component"

database_component="${CY_COMPONENT}-database"
database_component_name="${CY_COMPONENT_NAME}: Postgres"
cy component create --update \
  --component "$database_component"  \
  --name "$database_component_name" \
  --description "The database managed by ${CY_COMPONENT_NAME}" \
  --stack-ref "$stack_database_ref" --use-case "$USE_CASE" -o yaml
wait_for_component "$database_component"

caas_component="${CY_COMPONENT}-caas"
caas_component_name="${CY_COMPONENT_NAME}: CAAS"
cy component create --update \
  --component "$caas_component"  \
  --name "$caas_component_name" \
  --description "The caas managed by ${CY_COMPONENT_NAME}" \
  --stack-ref "$stack_caas_ref" --use-case "$USE_CASE" -o yaml
wait_for_component "$caas_component"
