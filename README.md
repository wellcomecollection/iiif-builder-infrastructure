# iiif-builder-infrastructure

Terraform infrastructure for [IIIF-Builder](https://github.com/wellcomecollection/iiif-builder) application.

Current Terraform version: 0.14.x

> Note: Networking infrastructure (VPC + Subnets) are managed in the central [platform-infrastructure](https://github.com/wellcomecollection/platform-infrastructure/) repository.

## Table of Contents

* [common](/infrastructure/common/readme.md)
  * Terraform that is not for any particular environment.
* [modules](/infrastructure/modules)
  * A collection of reusable modules for creating groups of resources.
* [staging](/infrastructure/staging)
  * References _common_ and adds resources specific to the Staging environment.
* [production](/infrastructure/production)
  * References _common_ and adds resources specific to the Production environment.

## Shared Infrastructure

Both Staging and Production share common infrastructure, including LoadBalancer. As such priority rules need to take into account all environments. The hostnames + priorities are:

| Priority | Rule                                                         |
|----------|--------------------------------------------------------------|
| 1        | iiif.wellcomecollection.org/dash* -> dashboard-prod          |
| 2        | iiif.wellcomecollection.org -> iiif-builder-prod             |
| 3        | iiif-stage.wellcomecollection.org/dash* -> dashboard-stage   |
| 4        | iiif-stage.wellcomecollection.org -> iiif-builder-stage      |
| 5        | iiif-test.wellcomecollection.org/dash* -> dashboard-stageprd |
| 6        | iiif-test.wellcomecollection.org -> iiif-builder-stageprd    |
| 7        | iiif-stage.dlcs.io -> iiif-builder-stage                     |
| 8        | dds-stage.dlcs.io -> dashboard-stage                         |
| 9        | iiif-test.dlcs.io -> iiif-builder-stageprd                   |
| 10       | dds-test.dlcs.io -> dashboard-stageprd                       |
| 11       | iiif.dlcs.io -> iiif-builder-prod                            |
| 12       | dds.dlcs.io -> dashboard-prod                                |

## Permissions

Assumed roles are used for accessing AWS. When using this Terraform, 2 profiles are needed as resources are used from different AWS accounts.

1. `main-wellcome` 
  - the 'main' Wellcome Cloud account. 
  - this is only used for accessing resources not in the main dlcs AWS account (`data "terraform_remote_state" "platform_infra"` resources).
2. `dev-wellcome` 
  - the profile that uses `main-wellcome` as source_profile to assume `digirati-developer` iam role. 
  - used for all resources in main dlcs AWS account (`provider`, `terraform` and other `data "terraform_remote_state"`).

> There may be other/better ways to achieve this!

