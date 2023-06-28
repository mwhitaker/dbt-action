# how to build the Docker image and send to Docker Hub

update the references in the Dockerfile to current ones.

using the dbt [Dockerfile](https://github.com/dbt-labs/dbt-core/blob/main/docker/Dockerfile) as a template.

`docker build --tag mwhitaker/dbt_all:v1.5.0  --target dbt-all .`

`docker push mwhitaker/dbt_all:v1.5.0`