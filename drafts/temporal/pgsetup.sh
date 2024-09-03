export SQL_PLUGIN=postgres12
export SQL_HOST=postgresql01.kube01.icncd.ru
export SQL_PORT=5432
export SQL_TLS=1
export SQL_TLS_CA_FILE=$HOME/.postgresql/root.crt
export SQL_TLS_CERT_FILE=$HOME/.postgresql/postgresql.crt
export SQL_TLS_KEY_FILE=$HOME/.postgresql/postgresql.key

make temporal-sql-tool

./temporal-sql-tool --database temporal create-database
SQL_DATABASE=temporal ./temporal-sql-tool setup-schema -v 0.0
SQL_DATABASE=temporal ./temporal-sql-tool update -schema-dir schema/postgresql/v12/temporal/versioned

./temporal-sql-tool --database temporal_visibility create-database
SQL_DATABASE=temporal_visibility ./temporal-sql-tool setup-schema -v 0.0
SQL_DATABASE=temporal_visibility ./temporal-sql-tool update -schema-dir schema/postgresql/v12/visibility/versioned
