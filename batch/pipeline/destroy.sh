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
      location: ((location))
  Database:
    Settings:
      virtual_network_name: "main-network" # ((virtual_network_name))
      sku: "((sku))"
      backup_retention_days: ((backup_retention_days))
      user: ((user)))
      database: ((database)))
      engine_version: ((engine_version)))
      resource_group_name: ((resource_group_name)))
  Configuration:
    Infrastructure:
      db_name: # We know it
    Application:
      demo_gitlab_project: ((demo_gitlab_project))
      web_image_version: ((web_image_version))
EOF
yq -r ".${USE_CASE}"
)$

STACKS="$(cy stack list -o json)"
stack_network_ref="$(echo "$STACKS" | jq -r '.[] | select(.canonical == "network") | .ref')"
stack_database_ref="$(echo "$STACKS" | jq -r '.[] | select(.canonical == "database") | .ref')"
stack_caas_ref="$(echo "$STACKS" | jq -r '.[] | select(.canonical == "caas") | .ref')"

export CY_STACKFORMS_VAR
wait_for_component() {
  local component=${1:?component as first arg}
  while
    status="$(curl "${CY_API_URL}/organizations/${CY_ORG}/projects/${CY_PROJECT}/environments/${CY_ENV}/components/${component}/pipelines/${CY_PROJECT}-${CY_ENV}-${component}/jobs/deploy/builds" \
    -H 'Accept: application/json' \
    -H "authorization: Bearer ${CY_API_KEY}" \
    -H 'content-type: application/vnd.cycloid.io.v1+json' \
    )"
    status="$(echo "$status" | jq -r .data.[0].status)"
    [[ "${status:-}" != "succeeded" ]]
  do echo "waiting for network to deploy"; sleep 1; done
}
set -x
network_component="${CY_COMPONENT}-network"
network_component_name="${CY_COMPONENT_NAME}: Network"
cy component create --update \
  --component "$network_component"  \
  --name "$network_component_name" \
  --description "The network landing zone for ${CY_COMPONENT_NAME}" \
  --stack-ref "$stack_network_ref" --use-case "$USE_CASE"
wait_for_component $network_component

database_component="${CY_COMPONENT}-database"
database_component_name="${CY_COMPONENT_NAME}: Postgres"
cy component create --update \
  --component "$database_component"  \
  --name "$database_component_name" \
  --description "The database managed by ${CY_COMPONENT_NAME}" \
  --stack-ref "$stack_database_ref" --use-case "$USE_CASE"
wait_for_component $database_component

caas_component="${CY_COMPONENT}-caas"
caas_component_name="${CY_COMPONENT_NAME}: CAAS"
cy component create --update \
  --component "$caas_component"  \
  --name "$caas_component_name" \
  --description "The caas managed by ${CY_COMPONENT_NAME}" \
  --stack-ref "$stack_caas_ref" --use-case "$USE_CASE"
wait_for_component $caas_component
