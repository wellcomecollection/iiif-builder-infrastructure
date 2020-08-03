# Staging

Infrastructure for IIIF-Builder Staging environment

## Configurations

There are 2 configurations for the 4 main services, these correspond to the `ASPNETCORE_ENVIRONMENT` value for each environment:

Both configurations use the same RDS instance with separate databases. The databases share the same user across configurations.

ECS tasks are scheduled to turn off at 1900 and back on again at 0700 UTC.

### Staging

Uses Staging database, DLCS and Storage API.

### Staging-Prod

Uses Staging database, DLCS and _production_ Storage API. Hostnames use `test` for this environment.
