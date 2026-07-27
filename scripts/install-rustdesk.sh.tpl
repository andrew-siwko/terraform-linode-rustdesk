#!/bin/bash
# Installed via Linode StackScript (terraform-linode-rustdesk).
# Installs Docker and brings up the RustDesk hbbs/hbbr relay server.
set -euo pipefail

exec > >(tee /var/log/rustdesk-install.log) 2>&1

echo "=== Installing Docker ==="
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable --now docker

echo "=== Waiting for attached data volume ==="
mkdir -p /opt/rustdesk
mkdir -p /opt/rustdesk/data
VOLUME_DEV="/dev/disk/by-id/scsi-0Linode_Volume_rustdesk-data"
for i in $(seq 1 60); do
  if [ -e "$VOLUME_DEV" ]; then
    break
  fi
  sleep 5
done

if [ -e "$VOLUME_DEV" ]; then
  if ! blkid "$VOLUME_DEV" > /dev/null 2>&1; then
    echo "=== No filesystem found on volume - formatting (first attach) ==="
    mkfs.ext4 "$VOLUME_DEV"
  else
    echo "=== Existing filesystem found on volume - preserving data across rebuild ==="
  fi
  mount "$VOLUME_DEV" /opt/rustdesk/data
  if ! grep -q "$VOLUME_DEV" /etc/fstab; then
    echo "$VOLUME_DEV /opt/rustdesk/data ext4 defaults,noatime 0 2" >> /etc/fstab
  fi
else
  echo "WARNING: data volume not found after waiting - falling back to local instance disk (NOT persistent across rebuilds)"
fi

echo "=== Writing RustDesk compose file ==="
cat > /opt/rustdesk/docker-compose.yml << 'COMPOSE'
services:
  hbbs:
    image: rustdesk/rustdesk-server:latest
    container_name: hbbs
    command: hbbs -r ${relay_fqdn}:21117
    volumes:
      - /opt/rustdesk/data:/root
    network_mode: host
    restart: unless-stopped

  hbbr:
    image: rustdesk/rustdesk-server:latest
    container_name: hbbr
    command: hbbr
    volumes:
      - /opt/rustdesk/data:/root
    network_mode: host
    restart: unless-stopped
COMPOSE

echo "=== Starting RustDesk server ==="
cd /opt/rustdesk
docker compose up -d

echo "=== Waiting for keypair to be generated ==="
for i in $(seq 1 30); do
  if [ -f /opt/rustdesk/data/id_ed25519.pub ]; then
    break
  fi
  sleep 2
done

if [ -f /opt/rustdesk/data/id_ed25519.pub ]; then
  echo "=== RustDesk server public key ==="
  cat /opt/rustdesk/data/id_ed25519.pub | tee /root/rustdesk_pubkey.txt
else
  echo "WARNING: public key not found after waiting - check 'docker logs hbbs'"
fi

echo "=== Done. Relay address configured as: ${relay_fqdn}:21117 ==="
