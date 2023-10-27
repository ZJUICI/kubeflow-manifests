#!/bin/bash

# postgres image has no `/bin/env`

set -e

dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt - Running init script the 1st time Primary PostgreSql container is created...";

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
CREATE USER $DEX_USERNAME WITH PASSWORD '$DEX_PASSWORD';
CREATE DATABASE $DEX_DATABASE;
ALTER DATABASE $DEX_DATABASE OWNER to $DEX_USERNAME;
EOSQL

echo "$dt - Init script is completed";
