#!/bin/bash
# Backup de WordPress: base de datos + archivos
set -euo pipefail
source /etc/backup-wp.conf

FECHA=$(date +%F_%H-%M)
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

mysqldump --single-transaction "$DB_NAME" > "$BACKUP_DIR/db_$FECHA.sql"
tar -czf "$BACKUP_DIR/files_$FECHA.tar.gz" -C "$WEB_ROOT" .
find "$BACKUP_DIR" -type f -mtime +"$RETENTION_DAYS" -delete

echo "[$(date '+%F %T')] Backup OK: $FECHA"
