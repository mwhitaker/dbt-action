ARG DBT_VERSION=0.19.1
FROM fishtownanalytics/dbt:${DBT_VERSION}
RUN apt-get update && apt-get install libsasl2-dev

RUN pip install --no-cache-dir --upgrade pip && \
    pip install dbt-spark dbt-spark[PyHive]

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
