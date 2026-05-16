SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Optional local overrides (credentials, endpoints). Not committed.
[[ -f "${SCRIPT_DIR}/vars.local.sh" ]] && source "${SCRIPT_DIR}/vars.local.sh"

BINARY_DIR="${SCRIPT_DIR}/binary"
S3_K3S_PREFIX="${S3_K3S_PREFIX:-database-backups/k3s}"

# Keep binary, install script, and airgap tarball on the same k3s release.
K3S_VERSION="v1.32.6+k3s1"
K3S_AIRGAP_IMAGES="${K3S_AIRGAP_IMAGES:-k3s-airgap-images-amd64.tar.gz}"
K3S_BINARY_NAME="${K3S_BINARY_NAME:-k3s}"
K3S_INSTALL_SCRIPT="${K3S_INSTALL_SCRIPT:-install.sh}"

K3S_IMAGES_DIR="/var/lib/rancher/k3s/agent/images"

K3S_ROLE="${K3S_ROLE:-server}"
K3S_URL="${K3S_URL:-https://127.0.0.1:6443}"
K3S_TOKEN="${K3S_TOKEN:-}"
# Traefik stays enabled (default). Do not pass --disable=traefik.
INSTALL_K3S_EXEC="${INSTALL_K3S_EXEC:---write-kubeconfig-mode 644}"
K3S_TLS_SAN="${K3S_TLS_SAN:-}"

S3_ENDPOINT="${S3_ENDPOINT:-https://s3.ir-thr-at1.arvanstorage.ir}"
S3_ACCESS_KEY="${S3_ACCESS_KEY:-}"
S3_SECRET_KEY="${S3_SECRET_KEY:-}"
