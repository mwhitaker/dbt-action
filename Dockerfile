ARG DBT_VERSION=0.21.0
FROM fishtownanalytics/dbt:${DBT_VERSION}
RUN apt-get update && apt-get install libsasl2-dev

# Need to re-declare the ARG to use its default value defined before the FROM
ARG DBT_VERSION
RUN pip install --no-cache-dir --upgrade pip && \
    pip install dbt-spark[PyHive]==${DBT_VERSION}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
