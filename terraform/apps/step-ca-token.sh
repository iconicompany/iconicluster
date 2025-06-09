#!/bin/bash
# Step CA token generator
# BASED ON https://gist.github.com/irvingpop/968464132ded25a206ced835d50afa6b
# ssh_key_generator - designed to work with the Terraform External Data Source provider
#   https://www.terraform.io/docs/providers/external/data_source.html
#  by Irving Popovetsky <irving@popovetsky.com> 
#  DEBUG statements may be safely uncommented as they output to stderr
set -e

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function check_deps() {
  test -f $(which step) || error_exit "step command not detected in path, please install it"
  test -f $(which jq) || error_exit "jq command not detected in path, please install it"
}

function parse_input() {
  # jq reads from stdin so we don't have to set up any inputs, but let's validate the outputs
  eval "$(jq -r '@sh "export STEP_CA_URL=\(.STEP_CA_URL) STEP_FINGERPRINT=\(.STEP_FINGERPRINT) CN=\(.CN) STEP_PROVISIONER=\(.STEP_PROVISIONER) STEP_PASSWORD_FILE=\(.STEP_PASSWORD_FILE) STEP_SSH=\(.STEP_SSH) STEP_HOST=\(.STEP_HOST) STEP_USER=\(.STEP_USER) STEPPATH=\(.STEPPATH)"')"
  if [[ -z "${STEP_PROVISIONER}" ]]; then error_exit "STEP_PROVISIONER required"; fi
  if [[ -z "${STEP_PASSWORD_FILE}" ]]; then error_exit "STEP_PASSWORD_FILE required"; fi
  if [[ "${STEP_CA_URL}" == "null" ]]; then unset STEP_CA_URL; fi
  if [[ "${STEP_SSH}" == "null" ]]; then unset STEP_SSH; fi
  if [[ "${STEP_HOST}" == "null" ]]; then unset STEP_HOST; fi
  if [[ "${STEP_USER}" == "null" ]]; then unset STEP_USER; fi
  if [[ "${STEPPATH}" == "null" ]]; then export STEPPATH=/etc/step-ca; fi
}

function produce_output() {
  TOKEN=$(step ca token ${CN})
  jq -n \
    --arg TOKEN "${TOKEN}" \
    '{"TOKEN":$TOKEN}'
}

# main()
check_deps
#echo "DEBUG: received: $INPUT" 1>&2
parse_input
produce_output
