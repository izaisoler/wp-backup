# Backups automáticos de WordPress

Scripts para hacer backup (BD + archivos) y restaurar un WordPress sobre Apache + MariaDB.

## Instalación (en la VM)
```
git clone https://github.com/TU_USUARIO/wp-backup.git
cd wp-backup
sudo ./install.sh
```
Esto instala los scripts en `/usr/local/bin`, crea `/etc/backup-wp.conf`,
programa el cron diario a las 2:00 y lanza un primer backup.

## Uso
| Acción | Comando |
|---|---|
| Backup manual | `sudo backup-wp.sh` |
| Restaurar el último | `sudo restore-wp.sh` |
| Restaurar uno concreto | `sudo restore-wp.sh 2026-10-19_02-00` |
| Migrar a otro servidor (cambia la URL) | `sudo restore-wp.sh FECHA http://NUEVA_URL` |
| Probar todo (simula desastre) | `sudo test-restore-wp.sh` |

## Migración a un segundo servidor
1. En el servidor nuevo instala Apache, PHP y MariaDB, y crea el usuario de BD como en el servidor original.
2. Clona este repo e instala: `sudo ./install.sh`
3. Copia un backup: `scp /var/backups/wordpress/*_FECHA.* usuario@NUEVO:/var/backups/wordpress/`
4. Restaura: `sudo restore-wp.sh FECHA http://NUEVA_URL`

## Configuración
Edita `/etc/backup-wp.conf` (nombre de BD, ruta web, retención).

## Seguridad
Los backups contienen `wp-config.php` y la BD completa: **nunca los subas a GitHub** (el `.gitignore` ya los excluye).
