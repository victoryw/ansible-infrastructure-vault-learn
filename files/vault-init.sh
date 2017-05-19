#!/usr/bin/env bash
echo $1
docker exec  $1 vault write -address=$2 secret/my-application password=H@rdT0Gu3ss 1>/dev/null || exit 125
docker exec  $1 vault mount -address=$2 postgresql 1>/dev/null || exit 125
docker exec  $1 vault write -address=$2 postgresql/config/connection \
    connection_url="postgres://postgres:r0ys1ngh4m@db:5432/vaultdb?sslmode=disable" 1>/dev/null || exit 125
docker exec  $1 vault write -address=$2 postgresql/config/lease lease=1h lease_max=24h 1>/dev/null || exit 125
docker exec  $1 vault write -address=$2 postgresql/roles/operator \
    sql="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" 1>/dev/null || exit 125
docker exec  $1 vault write -address=$2 secret/migrator \
    username="vaultuser" \
    password="r0ys1ngh4m" \
    1>/dev/null || exit 125
