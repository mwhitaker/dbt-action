# dbt-snowflake adapter pulls in dependencies such as dbt-core
FROM ghcr.io/dbt-labs/dbt-snowflake:1.0.latest
RUN apt-get update && apt-get install --no-install-recommends -y

RUN pip install --no-cache-dir --upgrade pip

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
