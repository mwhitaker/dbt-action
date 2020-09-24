# dbt action

A GitHub Action to run [dbt](https://www.getdbt.com) commands in a Docker container. You can use [dbt commands](https://docs.getdbt.com/reference/dbt-commands) such as `run`, `test` and `debug`. This action captures the dbt console output for use in subsequent steps. 

## Usage

```yml
    - name: dbt-actions
      uses: mwhitaker/dbt-actions@master
      with:
        dbt_command: "dbt run --profiles-dir ."
      env:
        DBT_BIGQUERY_TOKEN: ${{ secrets.DBT_BIGQUERY_TOKEN }}
```
### Outputs

You can grab the result output `passed|failed` of this action if you want to use it in a next step:

```yml
    - name: dbt-actions
      id: dbt-run
      uses: mwhitaker/dbt-actions@master
      with:
        dbt_command: "dbt run --profiles-dir ."
      env:
        DBT_BIGQUERY_TOKEN: ${{ secrets.DBT_BIGQUERY_TOKEN }}
    - name: Get the result
      run: echo "${{ steps.dbt-run.outputs.result }}"
      shell: bash
```
The result output is also saved in the `DBT_RUN_STATE` environment variable. The location of the dbt console log output can be accessed via `DBT_LOG_PATH`. See the "Suggested workflow" section on how to use them.

### General Setup

This action assumes that your dbt project is in the top-level directory of your repo, such as this [sample dbt project](https://github.com/fishtown-analytics/jaffle_shop). If your dbt project files are in a folder, you can specify it as such:

```yml
    - name: dbt-actions
      uses: mwhitaker/dbt-actions@master
      with:
        dbt_command: "dbt run --profiles-dir ."
        dbt_project_folder: "dbt_project"
      env:
        DBT_BIGQUERY_TOKEN: ${{ secrets.DBT_BIGQUERY_TOKEN }}
```
**Important:** dbt projects use a `profiles.yml` file to connect to your dataset. **dbt-actions** currently requires `profiles.yml` to be in your repo, alongside the `dbt_project.yml` file. 

```yml
# profiles.yml
my_dataset: # this needs to match the profile: in your dbt_project.yml file
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      keyfile: ./creds.json # THIS FILE WILL BE GENERATED USING SECRETS DURING BUILD TIME
      project: gcloud-project # Replace this with your project id
      dataset: mydataset # Replace this with dbt_your_name, e.g. dbt_bob
      threads: 1
      timeout_seconds: 300
      location: US
      priority: interactive
```
Note that the `./creds.json` keyfile is generated during build time using [secrets](https://docs.github.com/en/actions/reference/encrypted-secrets), so your service account credentials are not exposed in the repo.

### Setup for BigQuery

Connecting to **BigQuery** requires a service account file with the right permissions to access your dataset. Download the service account file outside your repo so that it doesn't get committed to your repo. Then generate a **Base64** encoded version of it using your Terminal:

```bash
cat service_acount.json | base64
#
# output should look like this
$ ewogICAgInR5cGUiOiAic2VydmljZV9hY2NvdW50IiwKICAgICJwcm9qZWN0X2lkIjogInRlc3QtcHJvamVjdCIsCiAgICAicHJpdmF0ZV9rZXlfaWQiOiAiMTIzNDU2Nzc4ODkiLAogICAgInByaXZhdGVfa2V5IjogIi0tLS0tQkVHSU4gUFJJVkFURSBLRVktLS0tLVxubjlLakpHNGNqWFFvWDBwOUJMV2xRPT1cbi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS1cbiIsCiAgICAiY2xpZW50X2VtYWlsIjogImRidC11c2VyQGF0ZXN0LXByb2plY3QuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLAogICAgImNsaWVudF9pZCI6ICIxMDk4NzY1NDMyMTAiLAogICAgImF1dGhfdXJpIjogImh0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbS9vL29hdXRoMi9hdXRoIiwKICAgICJ0b2tlbl91cmkiOiAiaHR0cHM6Ly9vYXV0aDIuZ29vZ2xlYXBpcy5jb20vdG9rZW4iLAogICAgImF1dGhfcHJvdmlkZXJfeDUwOV9jZXJ0X3VybCI6ICJodHRwczovL3d3dy5nb29nbGVhcGlzLmNvbS9vYXV0aDIvdjEvY2VydHMiLAogICAgImNsaWVudF94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3JvYm90L3YxL21ldGFkYXRhL3g1MDkvZGJ0LXVzZXIlNDBhbmFseXRpY3MtYnVkZHktaW50ZXJuYWwuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iCiAgfQ==
```
Create a new [secret](https://docs.github.com/en/actions/reference/encrypted-secrets) in your repo with the name `DBT_BIGQUERY_TOKEN` and paste in the encoded string and save the secret.

### Setup for other Databases
Databases that specify username/password in `profiles.yml` should be setup like this:

```yml
# profiles.yml
my_dataset:
  outputs:
    dev:
      type: postgres
      host: localhost
      user: _user_      # this will be substituted during build time
      pass: _password_  # this will be substituted during build time
      port: 5432
      dbname: tutorial
      schema: dbt_tutorial
  target: dev
```
Create a secret for `DBT_USER` and `DBT_PASSWORD` and reference them in your workflow.
```yml
    - name: dbt-actions
      uses: mwhitaker/dbt-actions@master
      with:
        dbt_command: "dbt run --profiles-dir ."
      env:
        DBT_USER: ${{ secrets.DBT_USER }}
        DBT_PASSWORD: ${{ secrets.DBT_PASSWORD }}
```
Please note that I have only tested BigQuery and Postgres. If you cannot connect to another database, please submit an [issue](https://github.com/mwhitaker/dbt-actions/issues) and we'll figure it out.

## Suggested workflow

Here is a [sample workflow](https://github.com/mwhitaker/dbt-action-sample) that sends dbt console logs by email.

## Bugs and feature requests
Please submit via [Github issues](https://github.com/mwhitaker/dbt-actions/issues).
## License

[MIT](LICENSE)