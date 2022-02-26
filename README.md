# Seafile Docker

Seafile docker image for easy and fast setup, built on the awesome work by **foxel** and **gip-recia**. See their repos in credits.

## Quickstart

* Use the provided `docker-compose.yml` configuration. You should change environment variables as needed.
* Start the services with `docker compose up -d`
* Check the logs: `docker compose logs -f`. The setup should be complete once you see that 
  * Mysql db is listening for incoming connections
  * Seafile "*Successfully created seafile admin*"
* Connect to http://localhost and login with provided `ADMIN_EMAIL` and `ADMIN_PASSWORD` values.

> ⚠️ Think about using secrets to protect your variables, or at the very least, a .env file.

## Environment variables

- `MYSQL_ROOT_PASSWORD` (or `MYSQL_ROOT_PASSWD`, `MARIADB_ROOT_PASSWORD`)
- `MYSQL_HOST` (default: `mariadb`)
- `ADMIN_EMAIL` (default: `admin@example.com`)
- `ADMIN_PASSWORD` (default: `admin`)
- `USE_EXISTING_DB` (default: `0`) - Set to `1` if database already exists. This will create databases by default.
- `SERVER_NAME` (default: `seafile`)
### Database Names
- `CCNET_DB` (default: `ccnet-db`)
- `SEAFILE_DB` (default: `seafile-db`)
- `SEAHUB_DB` (default: `seahub-db`)


## UPGRADING

Upgrading is possible in step-by-step manner:

### 8.0.x => 9.0.x
```
docker-compose exec seafile /scripts/upgrade.sh 9.0.0
```

### 7.1.x => 8.0.x
```
docker-compose exec seafile /scripts/upgrade.sh 8.0.0
```

## Credits

This image was built merging and updating from the great work already done here:
- https://github.com/foxel/seafile-docker - the main repo
- https://github.com/GIP-RECIA/seafile-docker/tree/automated-setup - for automated setup



### Etc

```
docker-compose exec seafile /scripts/upgrade.sh X.0.0
```

