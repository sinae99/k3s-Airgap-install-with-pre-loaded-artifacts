# k3s Airgap Helper

A tiny shell-based workflow for downloading K3s artifacts from object storage and installing them on an offline server.

## Start

1. Copy the local config template:
   ```bash
   cp vars.local.sh.example vars.local.sh
   ```
2. Edit `vars.local.sh` with your storage endpoint, prefix, and credentials.
3. Run `./download-from-s3.sh` on a machine with internet access.
4. Copy the `binary/` directory to the offline server.
5. Run `sudo ./install.sh` on the target host.

## Note

- Save these exact files in object storage so `download-from-s3.sh` can copy them into `binary/`:
  - `k3s-airgap-images-amd64.tar.gz`
  - `k3s`
  - `install.sh`
- For agent installs, set `K3S_ROLE=agent`, `K3S_URL`, and `K3S_TOKEN` in `vars.local.sh`.
