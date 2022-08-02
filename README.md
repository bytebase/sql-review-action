# Bytebase SQL Review Action

The GitHub Action for SQL Review. Parse and check the SQL statement according to the SQL review rules.

## Usage

Create a file in `.github/workflows/sql-review.yml` in your repository and insert the following content.

```yml
on: [pull_request]

jobs:
  sql-review:
    runs-on: ubuntu-latest
    name: SQL Review
    steps:
      - uses: actions/checkout@v3
      - name: Check SQL
        uses: bytebase/sql-review-action@main
        with:
          override: "<Your SQL review rules configuration file path>" # Optional, we can only provide the template id
          database: "<Database type>"
          template: "<SQL review rule template id>" # Optional. Required if the override is not specified.
```

This action will be triggered in the pull request if you have any SQL files changed. It will call the SQL review service to check if is valid according to the SQL review rules.

### About parameters

- `override`: Your SQL review rules configuration file path. **Optional** if you provide the template id and don't want to customize rules.
- `database`: Your database type. **Required**, should be one of "MYSQL", "POSTGRES" or "TIDB".
- `template`: The SQL Review rule template id. **Optional** if you provide the `override` parameter. Should be one of "bb.sql-review.prod", "bb.sql-review.dev".

## Example

Go to `./example/` folder to see how to configure the workflow and override SQL review rules.

Go to [bytebase](https://github.com/bytebase/bytebase) for a real example.
