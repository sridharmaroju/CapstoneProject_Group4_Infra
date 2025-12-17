#!/bin/bash
ACCOUNT_SECRET="${account_secret_arn}"
DB_SECRET="${db_secret_arn}"
# rest of your scrip

dnf update -y

dnf install -y mariadb105

ACOUNT_SECRET_JSON=$(aws secretsmanager get-secret-value \
--secret-id "$${ACCOUNT_SECRET}" \
--query SecretString \
--output text)

DB_USERNAME=$(echo "$ACOUNT_SECRET_JSON" | jq -r .username)
DB_PASSWORD=$(echo "$ACOUNT_SECRET_JSON" | jq -r .password)

DB_SECRET_JSON=$(aws secretsmanager get-secret-value \
--secret-id "$${DB_SECRET}" \
--query SecretString \
--output text)

DB_HOST=$(echo "$DB_SECRET_JSON" | jq -r .host)
DB_DBNAME=$(echo "$DB_SECRET_JSON" | jq -r .database)

mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DBNAME" <<EOF
CREATE TABLE IF NOT EXISTS CARDS ( CARD_ID VARCHAR(36) NOT NULL, USER_ID VARCHAR(36) NULL, BALANCE DOUBLE NOT NULL DEFAULT 0.00, PRIMARY KEY (CARD_ID) );
CREATE TABLE IF NOT EXISTS TRANSACTIONS (TRANSACTION_ID BIGINT NOT NULL AUTO_INCREMENT, CARD_ID VARCHAR(36) NOT NULL, TYPE SMALLINT NOT NULL, AMOUNT DOUBLE NOT NULL, TRANSACTION_DATETIME DATETIME NOT NULL, PRIMARY KEY (TRANSACTION_ID), INDEX idx_card_id (CARD_ID));
EOF