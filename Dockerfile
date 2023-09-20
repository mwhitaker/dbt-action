ARG DBT_VERSION=v1.6.3
FROM mwhitaker/dbt_all:${DBT_VERSION}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
