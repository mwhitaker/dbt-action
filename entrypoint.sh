#!/bin/bash

set -o pipefail

echo "dbt project folder set as: \"${INPUT_DBT_PROJECT_FOLDER}\""
echo "dbt profile folder set as: \"${INPUT_DBT_PROFILE_FOLDER}\""
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
 cp ${INPUT_DBT_PROFILE_FOLDER}/profiles.yml .
 sed -i "s/_user_/${DBT_USER}/g" ./profiles.yml
 sed -i "s/_password_/${DBT_PASSWORD}/g" ./profiles.yml
elif [ -n "${DBT_TOKEN}" ]
then
 echo trying to use DBT_TOKEN/databricks
 cp ${INPUT_DBT_PROFILE_FOLDER}/datab.yml .
 sed -i "s/_token_/${DBT_TOKEN}/g" ./datab.yml
else
  echo no tokens or credentials supplied
fi

DBT_ACTION_LOG_FILE=${DBT_ACTION_LOG_FILE:="dbt_console_output.txt"}
DBT_ACTION_LOG_PATH="${INPUT_DBT_PROJECT_FOLDER}/${DBT_ACTION_LOG_FILE}"
echo "DBT_ACTION_LOG_PATH=${DBT_ACTION_LOG_PATH}" >> $GITHUB_ENV
echo "saving console output in \"${DBT_ACTION_LOG_PATH}\""
$1 2>&1 | tee "${DBT_ACTION_LOG_FILE}"
if [ $? -eq 0 ]
  then
    echo "DBT_RUN_STATE=passed" >> $GITHUB_ENV
    echo "result=passed" >> $GITHUB_OUTPUT
    echo "DBT run OK" >> "${DBT_ACTION_LOG_FILE}"
  else
    echo "DBT_RUN_STATE=failed" >> $GITHUB_ENV
    echo "result=failed" >> $GITHUB_OUTPUT
    echo "DBT run failed" >> "${DBT_ACTION_LOG_FILE}"
    exit 1
fi
