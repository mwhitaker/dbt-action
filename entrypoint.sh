#!/bin/bash

set -o pipefail

echo "dbt project folder set as: \"${INPUT_DBT_PROJECT_FOLDER}\""
cd ${INPUT_DBT_PROJECT_FOLDER}

if [ -n "${DBT_BIGQUERY_TOKEN}" ]
then
  echo trying to parse bigquery token
  $(echo ${DBT_BIGQUERY_TOKEN} | base64 -d > ./creds.json 2>/dev/null)
  if [ $? -eq 0 ]
  then
    echo success parsing base64 encoded token
  elif $(echo ${DBT_BIGQUERY_TOKEN} > ./creds.json)
  then
    echo success parsing plain token
  else
    echo cannot parse bigquery token
    exit 1
  fi
elif [ -n "${DBT_USER}" ] && [ -n "$DBT_PASSWORD" ]
then
 echo trying to use user/password
 sed -i "s/_user_/${DBT_USER}/g" ./datab.yml
 sed -i "s/_password_/${DBT_PASSWORD}/g" ./profiles.yml
elif [ -n "${DBT_TOKEN}" ]
then
 echo trying to use DBT_TOKEN/databricks
 sed -i "s/_token_/${DBT_TOKEN}/g" ./profiles.yml
else
  echo no tokens or credentials supplied
fi

DBT_LOG_FILE=${DBT_LOG_FILE:="dbt_console_output.txt"}
DBT_LOG_PATH="${INPUT_DBT_PROJECT_FOLDER}/${DBT_LOG_FILE}"
echo "DBT_LOG_PATH=${DBT_LOG_PATH}" >> $GITHUB_ENV
echo "saving console output in \"${DBT_LOG_PATH}\""
$1 2>&1 | tee "${DBT_LOG_FILE}"
if [ $? -eq 0 ]
  then
    echo "DBT_RUN_STATE=passed" >> $GITHUB_ENV
    echo "::set-output name=result::passed"
    echo "DBT run OK" >> "${DBT_LOG_FILE}"
  else
    echo "DBT_RUN_STATE=failed" >> $GITHUB_ENV
    echo "::set-output name=result::failed"
    echo "DBT run failed" >> "${DBT_LOG_FILE}"
    exit 1
fi
