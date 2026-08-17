#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
# shellcheck source=vars.sh
source ./vars.sh

required=(
  "${BINARY_DIR}/${K3S_BINARY_NAME}"
  "${BINARY_DIR}/${K3S_INSTALL_SCRIPT}"
  "${BINARY_DIR}/${K3S_AIRGAP_IMAGES}"
)
for f in "${required[@]}"; do
  [[ -f "$f" ]] || { echo "Missing $f — run ./download-from-s3.sh on a host with internet first." >&2; exit 1; }
done

if [[ "$K3S_ROLE" == "agent" && -z "$K3S_TOKEN" ]]; then
  echo "K3S_TOKEN is required when K3S_ROLE=agent" >&2
  exit 1
fi

# Airgap: never download binary, hashes, channel metadata, or SELinux RPMs from the internet.
export INSTALL_K3S_SKIP_DOWNLOAD=true
export INSTALL_K3S_SKIP_SELINUX_RPM=true

sudo mkdir -p "$K3S_IMAGES_DIR"
sudo cp -f "${BINARY_DIR}/${K3S_AIRGAP_IMAGES}" "${K3S_IMAGES_DIR}/"
sudo install -m 755 "${BINARY_DIR}/${K3S_BINARY_NAME}" /usr/local/bin/k3s
chmod +x "${BINARY_DIR}/${K3S_INSTALL_SCRIPT}"

install_env=(INSTALL_K3S_SKIP_DOWNLOAD=true INSTALL_K3S_SKIP_SELINUX_RPM=true)
if [[ -n "$K3S_TLS_SAN" ]]; then
  INSTALL_K3S_EXEC="${INSTALL_K3S_EXEC} --tls-san ${K3S_TLS_SAN}"
fi

if [[ "$K3S_ROLE" == "server" ]]; then
  install_env+=(INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC")
  sudo -E env "${install_env[@]}" bash "${BINARY_DIR}/${K3S_INSTALL_SCRIPT}"
else
  install_env+=(K3S_URL="$K3S_URL" K3S_TOKEN="$K3S_TOKEN")
  sudo -E env "${install_env[@]}" bash "${BINARY_DIR}/${K3S_INSTALL_SCRIPT}"
fi

echo "k3s ${K3S_ROLE} installed (airgap, Traefik enabled by default)."
