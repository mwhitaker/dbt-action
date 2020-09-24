ARG DBT_VERSION=0.17.2
FROM fishtownanalytics/dbt:${DBT_VERSION}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
