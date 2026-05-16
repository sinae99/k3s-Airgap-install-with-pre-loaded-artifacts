#!/bin/bash
set -euo pipefail
set -x

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
mkdir -p "$BINARY_DIR"

if ! command -v mc >/dev/null 2>&1; then
  echo "MinIO client (mc) is required on the online download host." >&2
  exit 1
fi

mc alias set arvan-s3 "$S3_ENDPOINT" "$S3_ACCESS_KEY" "$S3_SECRET_KEY"

for object in "$K3S_AIRGAP_IMAGES" "$K3S_BINARY_NAME" "$K3S_INSTALL_SCRIPT"; do
  mc cp "arvan-s3/${S3_K3S_PREFIX}/${object}" "${BINARY_DIR}/"
done
mc cp arvan-s3/database-backups/k3s/k3s
chmod +x "${BINARY_DIR}/${K3S_BINARY_NAME}" "${BINARY_DIR}/${K3S_INSTALL_SCRIPT}"
chmod +x binary/k3s
echo "Artifacts in ${BINARY_DIR}:"
ls -lh "${BINARY_DIR}/${K3S_AIRGAP_IMAGES}" "${BINARY_DIR}/${K3S_BINARY_NAME}" "${BINARY_DIR}/${K3S_INSTALL_SCRIPT}"
