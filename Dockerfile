ARG DBT_VERSION=v1.7.3
FROM ghcr.io/mwhitaker/dbt_all:${DBT_VERSION}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
