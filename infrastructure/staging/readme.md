# Staging

Infrastructure for IIIF-Builder Staging environment

## Configurations

There are 2 configurations for the 4 main services, these correspond to the `ASPNETCORE_ENVIRONMENT` value for each environment:

* Staging: Uses Staging database, DLCS and Storage API.
* Staging-Prod: Uses Staging database, DLCS and _production_ Storage API. 

Both configurations use the same RDS instance with separate databases. The databases share the same user across configurations.
