#!/bin/bash

set -o pipefail

echo "dbt project folder set as: \"${INPUT_DBT_PROJECT_FOLDER}\""
cd ${INPUT_DBT_PROJECT_FOLDER}


if [ -n "${DBT_BIGQUERY_TOKEN}" ] 
then
 echo ${DBT_BIGQUERY_TOKEN} | base64 -d > ./creds.json
fi

if [ -n "${DBT_USER}" ] && [ -n "$DBT_PASSWORD" ]
then
 sed -i "s/_user_/${DBT_USER}/g" ./profiles.yml
 sed -i "s/_password_/${DBT_PASSWORD}/g" ./profiles.yml
fi

DBT_LOG_FILE=${DBT_LOG_FILE:="dbt_console_output.txt"}
DBT_LOG_PATH="${INPUT_DBT_PROJECT_FOLDER}/${DBT_LOG_FILE}"
echo "DBT_LOG_PATH=${DBT_LOG_PATH}" >> $GITHUB_ENV
# echo "::set-env name=DBT_LOG_PATH::${DBT_LOG_PATH}"
echo "saving console output in \"${DBT_LOG_PATH}\""
$1 2>&1 | tee "${DBT_LOG_FILE}"
if [ $? -eq 0 ]
  then
    # echo "::set-env name=DBT_RUN_STATE::passed"
    echo "DBT_RUN_STATE=passed" >> $GITHUB_ENV
    echo "::set-output name=result::passed"
    echo "DBT run OK" >> "${DBT_LOG_FILE}"
  else
    # echo "::set-env name=DBT_RUN_STATE::failed"
    echo "DBT_RUN_STATE=failed" >> $GITHUB_ENV
    echo "::set-output name=result::failed"
    echo "DBT run failed" >> "${DBT_LOG_FILE}"
fi