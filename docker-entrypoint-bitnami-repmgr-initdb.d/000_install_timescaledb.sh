#!/bin/bash

create_sql=`mktemp`


POSTGRES_USER=${POSTGRESQL_USERNAME}
POSTGRES_PASSWORD=${POSTGRESQL_PASSWORD}
PGPASSWORD=${POSTGRESQL_PASSWORD} # for psql auth
POSTGRES_DB=${POSTGRESQL_DATABASE}

PGDATA='/bitnami/postgresql'

POSTGRESQL_CONF_DIR='/opt/bitnami/postgresql/conf'


cat <<EOF >${create_sql}
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
EOF

TS_TELEMETRY='basic'
if [ "${TIMESCALEDB_TELEMETRY:-}" == "off" ]; then
	TS_TELEMETRY='off'

	# We delete the job as well to ensure that we do not spam the
	# log with other messages related to the Telemetry job.
	cat <<EOF >>${create_sql}
SELECT alter_job(1,scheduled:=false);
EOF
fi

echo "timescaledb.telemetry_level=${TS_TELEMETRY}" >> ${POSTGRESQL_CONF_DIR}/postgresql.conf


# create extension timescaledb in initial databases
psql -U "${POSTGRES_USER}" postgres -f ${create_sql}
psql -U "${POSTGRES_USER}" template1 -f ${create_sql}

if [ "${POSTGRES_DB:-postgres}" != 'postgres' ]; then
    psql -U "${POSTGRES_USER}" "${POSTGRES_DB}" -f ${create_sql}
fi
