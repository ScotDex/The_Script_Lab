# The Script Lab

This repository contains various PowerShell scripts for API testing, tooling and development experiments.

## Providing Credentials

Some scripts require credentials. To avoid hard coding sensitive values, these scripts read their credentials from environment variables:

- `API_USERNAME` and `API_PASSWORD` for scripts in the `API` folder.
- `EVE_CLIENT_ID` and `EVE_CLIENT_SECRET` for EVE Online authentication scripts.
- `EVE_AUTH_CODE` for `Development/eve-auth-api-test.ps1`.
- `TEST_EMAIL` and `TEST_PASSWORD` for `Pen-Test/payload.ps1`.
- `ELASTIC_USERNAME` and `ELASTIC_PASSWORD` for `Tooling/elastic-rule-report.ps1`.

Before running a script, export the required variables in your shell:

```powershell
$env:API_USERNAME = 'myuser'
$env:API_PASSWORD = 'mypassword'
# set other variables as needed
```

Use your preferred secrets management solution to supply these values securely.

