#!/bin/bash
# Simula un desastre (borra web + BD) y restaura el último backup.
set -euo pipefail
source /etc/backup-wp.conf
[ "$EUID" -eq 0 ] || { echo "Ejecuta con sudo"; exit 1; }

echo "ATENCIÓN: esto BORRARÁ $WEB_ROOT y la base '$DB_NAME', y restaurará el último backup."
read -rp "Escribe SI para continuar: " R
[ "$R" = "SI" ] || { echo "Cancelado"; exit 1; }

/usr/local/bin/backup-wp.sh
find "$WEB_ROOT" -mindepth 1 -delete
mysql -e "DROP DATABASE \`$DB_NAME\`; CREATE DATABASE \`$DB_NAME\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo "Desastre simulado: comprueba que el sitio está roto y pulsa Enter para restaurar."
read -r
/usr/local/bin/restore-wp.sh
echo "Comprueba en el navegador que todo ha vuelto."
