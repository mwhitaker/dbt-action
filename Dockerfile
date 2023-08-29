FROM ghcr.io/dbt-labs/dbt-snowflake:1.6.1

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
