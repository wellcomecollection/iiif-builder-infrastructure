# Staging

Infrastructure for IIIF-Builder Staging environment

## Configurations

There are 2 configurations for the 4 main services, these correspond to the `ASPNETCORE_ENVIRONMENT` value for each environment:

Both configurations use the same RDS instance with separate databases. The databases share the same user across configurations.

ECS tasks are scheduled to turn off at 1900 and back on again at 0700 UTC.

> A note on scaling - the assumption is that any `tf apply` operations will be run when services are running (scaled-out). If run outside of these times there will be changes related to scale target.

### Staging

Uses Staging database, DLCS and Storage API.

### Staging-Prod

Uses Staging database, DLCS and _production_ Storage API. Hostnames use `test` for this environment.
