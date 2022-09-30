ARG DBT_VERSION=v1.2.1
FROM mwhitaker/dbt_all:${DBT_VERSION}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
