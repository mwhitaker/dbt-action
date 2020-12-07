ARG DBT_VERSION=0.18.1
FROM fishtownanalytics/dbt:${DBT_VERSION}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
