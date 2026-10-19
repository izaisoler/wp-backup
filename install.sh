#!/bin/bash
# Instala los scripts, la configuración y el cron diario (2:00).
set -euo pipefail
[ "$EUID" -eq 0 ] || { echo "Ejecuta con: sudo ./install.sh"; exit 1; }
cd "$(dirname "$0")"

install -m 755 backup-wp.sh   /usr/local/bin/backup-wp.sh
install -m 755 restore-wp.sh  /usr/local/bin/restore-wp.sh
install -m 755 test-restore.sh /usr/local/bin/test-restore-wp.sh
[ -f /etc/backup-wp.conf ] || install -m 600 backup-wp.conf /etc/backup-wp.conf

cat > /etc/cron.d/backup-wp <<CRON
0 2 * * * root /usr/local/bin/backup-wp.sh >> /var/log/backup-wp.log 2>&1
CRON
chmod 644 /etc/cron.d/backup-wp

echo "Instalado. Lanzando primer backup..."
/usr/local/bin/backup-wp.sh
ls -lh /var/backups/wordpress
echo
echo "Cron programado:"; cat /etc/cron.d/backup-wp
