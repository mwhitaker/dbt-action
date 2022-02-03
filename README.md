# dbt-action

A GitHub Action to run [dbt](https://www.getdbt.com) commands in a Docker container. It uses the official images provided by [Fishtown Analytics](https://hub.docker.com/r/fishtownanalytics/dbt/tags). You can use [dbt commands](https://docs.getdbt.com/reference/dbt-commands) such as `run`, `test` and `debug`. This action captures the dbt console output for use in subsequent steps.

### dbt version
The current version of dbt is 1.0.0. Please note that dbt v1.0.0. may require some changes to your dbt project structure compared to v0.x.x. See the [migration](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) docs.

dbt updates their [docker images](https://hub.docker.com/r/fishtownanalytics/dbt/tags?page=1&ordering=last_updated) on a frequent basis and the main branch of this Github Action should be close to the last stable tag. If you need to use an earlier version of dbt, you can call this action with a specific [branch](https://github.com/mwhitaker/dbt-action/branches), eg `mwhitaker/dbt-action@fishtown-v0.21.0` or `mwhitaker/dbt-action@fishtown-v0.19.1`.

You can also reference a [tagged](https://github.com/mwhitaker/dbt-action/releases) release, eg `mwhitaker/dbt-action@v0.1.9`.

## Usage

```yml
    - name: dbt-action
      uses: mwhitaker/dbt-action@master
      with:
        dbt_command: "dbt run --profiles-dir ."
      env:
        DBT_BIGQUERY_TOKEN: ${{ secrets.DBT_BIGQUERY_TOKEN }}
```
### Outputs

The result of the dbt command is either `failed` or `passed` and is saved into the result output if you want to use it in a next step:

```yml
    - name: dbt-action
      id: dbt-run
      uses: mwhitaker/dbt-action@master
      with:
        dbt_command: "dbt run --profiles-dir ."
      env:
        DBT_BIGQUERY_TOKEN: ${{ secrets.DBT_BIGQUERY_TOKEN }}
    - name: Get the result
      if: ${{ always() }}
      run: echo "${{ steps.dbt-run.outputs.result }}"
      shell: bash
```
The result output is also saved in the `DBT_RUN_STATE` environment variable. The location of the dbt console log output can be accessed via the environment variable `DBT_LOG_PATH`. See the "Suggested workflow" section on how to use these.

### General Setup

This action assumes that your dbt project is in the top-level directory of your repo, such as this [sample dbt project](https://github.com/fishtown-analytics/jaffle_shop). If your dbt project files are in a folder, you can specify it as such:

```yml
    - name: dbt-action
      uses: mwhitaker/dbt-action@master
      with:
        dbt_command: "dbt run --profiles-dir ."
        dbt_project_folder: "dbt_project"
      env:
        DBT_BIGQUERY_TOKEN: ${{ secrets.DBT_BIGQUERY_TOKEN }}
```
**Important:** dbt projects use a `profiles.yml` file to connect to your dataset. **dbt-action** currently requires `profiles.yml` to be in your repo, alongside the `dbt_project.yml` file. 

### Setup for BigQuery

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


Connecting to **BigQuery** requires a service account file with the right permissions to access your dataset. Download the service account json file outside your repo so that it doesn't accidentally get committed to your repo.

Create a new [secret](https://docs.github.com/en/actions/reference/encrypted-secrets) in your repo with the name `DBT_BIGQUERY_TOKEN` and paste in the contents of the json file. You can also use a base64 encoded version if you prefer: `cat service_account.json | base64`.

### Setup for databases using username/password
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
    - name: dbt-action
      uses: mwhitaker/dbt-action@master
      with:
        dbt_command: "dbt run --profiles-dir ."
      env:
        DBT_USER: ${{ secrets.DBT_USER }}
        DBT_PASSWORD: ${{ secrets.DBT_PASSWORD }}
```

### Setup for databricks
dbt-action was tested using the `http` method for databricks. A sample `profiles.yml` should look like this:

```yml
# profiles.yml
default:
  target: dev
  outputs:
    dev:
      type: spark
      method: http
      schema: dev_user
      host: abc-12345-3cc5.cloud.databricks.com
      port: 443
      token: _token_ # this will be substituted during build time
      cluster: 1234-56789-abc233
      connect_timeout: 30
      connect_retries: 15
      threads: 5
```
Create a secret for `DBT_TOKEN` and reference it in your workflow.
```yml
    - name: dbt-action
      uses: mwhitaker/dbt-action@master
      with:
        dbt_command: "dbt run --profiles-dir ."
      env:
        DBT_TOKEN: ${{ secrets.DBT_TOKEN }}
```

If you cannot connect to another database, please submit an [issue](https://github.com/mwhitaker/dbt-action/issues) and we'll figure it out.

## Suggested workflow and other tips

Here is a [sample workflow](https://github.com/mwhitaker/dbt-action-sample) that sends dbt console logs by email.

## Bugs and feature requests
Please submit via [Github issues](https://github.com/mwhitaker/dbt-action/issues).
## License

[MIT](LICENSE)