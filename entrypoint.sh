#!/bin/bash

set -o pipefail

echo "dbt project folder set as: \"${INPUT_DBT_PROJECT_FOLDER}\""
cd ${INPUT_DBT_PROJECT_FOLDER}

export PROFILES_FILE="${DBT_PROFILES_DIR:-.}/profiles.yml"
if [ -e "${PROFILES_FILE}" ]  # check if file exist
then
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
  sed -i "s/_user_/${DBT_USER}/g" $PROFILES_FILE
  sed -i "s/_password_/${DBT_PASSWORD}/g" $PROFILES_FILE
  elif [ -n "${DBT_TOKEN}" ]
  then
  echo trying to use DBT_TOKEN/databricks
  sed -i "s/_token_/${DBT_TOKEN}/g" $PROFILES_FILE
  else
    echo no tokens or credentials supplied
  fi

  if [ -n "${INPUT_HTTP_PATH}" ]
  then
  echo trying to use http_path for databricks
  sed -i "s/_http_path_/$(echo $INPUT_HTTP_PATH | sed 's/\//\\\//g')/g" $PROFILES_FILE
  fi
else
  echo "profiles.yml not found"
  exit 1
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
