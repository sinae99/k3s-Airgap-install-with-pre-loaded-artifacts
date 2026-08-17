#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# shellcheck source=vars.sh
source ./vars.sh

require_s3_credentials() {
  [[ -n "$S3_ACCESS_KEY" && -n "$S3_SECRET_KEY" ]] || {
    echo "Set S3_ACCESS_KEY and S3_SECRET_KEY in the environment or vars.local.sh" >&2
    exit 1
  }
}

require_s3_credentials
[[ -n "$S3_ENDPOINT" ]] || {
  echo "Set S3_ENDPOINT in vars.local.sh" >&2
  exit 1
}
mkdir -p "$BINARY_DIR"

if ! command -v mc >/dev/null 2>&1; then
  echo "MinIO client (mc) is required on the online download host." >&2
  exit 1
fi

mc alias set airgap-s3 "$S3_ENDPOINT" "$S3_ACCESS_KEY" "$S3_SECRET_KEY"

remote_prefix="${S3_K3S_PREFIX%/}"
for object in "$K3S_AIRGAP_IMAGES" "$K3S_BINARY_NAME" "$K3S_INSTALL_SCRIPT"; do
  if [[ -n "$remote_prefix" ]]; then
    mc cp "airgap-s3/${remote_prefix}/${object}" "${BINARY_DIR}/"
  else
    mc cp "airgap-s3/${object}" "${BINARY_DIR}/"
  fi
done
chmod +x "${BINARY_DIR}/${K3S_BINARY_NAME}" "${BINARY_DIR}/${K3S_INSTALL_SCRIPT}"
echo "Artifacts in ${BINARY_DIR}:"
ls -lh "${BINARY_DIR}/${K3S_AIRGAP_IMAGES}" "${BINARY_DIR}/${K3S_BINARY_NAME}" "${BINARY_DIR}/${K3S_INSTALL_SCRIPT}"
