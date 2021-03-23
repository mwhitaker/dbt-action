ARG DBT_VERSION=0.19.0
FROM fishtownanalytics/dbt:${DBT_VERSION}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
