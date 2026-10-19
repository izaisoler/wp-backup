#!/bin/bash
# Uso: sudo restore-wp.sh [FECHA] [NUEVA_URL]
#   FECHA      ej. 2026-10-19_02-00 (por defecto, el último backup)
#   NUEVA_URL  ej. http://192.168.1.50 (para migraciones)
set -euo pipefail
source /etc/backup-wp.conf

[ "$EUID" -eq 0 ] || { echo "Ejecuta con sudo"; exit 1; }

FECHA="${1:-}"
NEW_URL="${2:-}"

if [ -z "$FECHA" ]; then
  DB=$(ls -1t "$BACKUP_DIR"/db_*.sql 2>/dev/null | head -1 || true)
  [ -n "$DB" ] || { echo "No hay backups en $BACKUP_DIR"; exit 1; }
  FECHA="${DB##*/db_}"; FECHA="${FECHA%.sql}"
fi

DB_FILE="$BACKUP_DIR/db_$FECHA.sql"
FILES="$BACKUP_DIR/files_$FECHA.tar.gz"
[ -f "$DB_FILE" ] && [ -f "$FILES" ] || { echo "Faltan archivos del backup $FECHA"; exit 1; }

echo "Restaurando backup $FECHA ..."
mysql -e "DROP DATABASE IF EXISTS \`$DB_NAME\`; CREATE DATABASE \`$DB_NAME\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql "$DB_NAME" < "$DB_FILE"

mkdir -p "$WEB_ROOT"
find "$WEB_ROOT" -mindepth 1 -delete
tar -xzf "$FILES" -C "$WEB_ROOT"
chown -R www-data:www-data "$WEB_ROOT"

if [ -n "$NEW_URL" ]; then
  PREFIX=$(grep -oP "table_prefix\s*=\s*'\K[^']+" "$WEB_ROOT/wp-config.php" || echo "wp_")
  mysql "$DB_NAME" -e "UPDATE ${PREFIX}options SET option_value='$NEW_URL' WHERE option_name IN ('siteurl','home');"
  echo "URL del sitio cambiada a $NEW_URL"
fi

echo "Restauración completada."
