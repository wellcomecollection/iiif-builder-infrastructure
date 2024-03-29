# iiif-builder-infrastructure

Terraform infrastructure for [IIIF-Builder](https://github.com/wellcomecollection/iiif-builder) application.

Current Terraform version: 1.0.x

> Note: Networking infrastructure (VPC + Subnets) are managed in the central [platform-infrastructure](https://github.com/wellcomecollection/platform-infrastructure/) repository.

> Note: AWS account root is granted access to Wellcome storage buckets in [storage-service](https://github.com/wellcomecollection/storage-service/) repository.

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

| Priority | Rule                                                                                |
|----------|-------------------------------------------------------------------------------------|
| 1        | iiif.wellcomecollection.org/dash* -> dashboard-prod                                 |
| 3        | iiif-stage.wellcomecollection.org/dash* -> dashboard-stage                          |
| 5        | iiif-test.wellcomecollection.org/dash* -> dashboard-stageprd                        |
| 6        | pdf-stage.wellcomecollection.digirati.io -> pdf-generator-stage                     |
| 8        | dash-stage.wellcomecollection.digirati.io -> dashboard-stage                        |
| 10       | dash-test.wellcomecollection.digirati.io -> dashboard-stageprd                      |
| 24       | dash.wellcomecollection.digirati.io -> dashboard-prod                               |
| 25       | pdf.wellcomecollection.digirati.io -> pdf-generator-prod                            |
| 30       | dds-stage.wellcomecollection.digirati.io/text* -> iiif-builder-text-stage           |
| 31       | dds-stage.wellcomecollection.digirati.io/search* -> iiif-builder-text-stage         |
| 32       | iiif-stage.wellcomecollection.org/text* -> iiif-builder-text-stage                  |
| 33       | iiif-stage.wellcomecollection.org/search* -> iiif-builder-text-stage                |
| 34       | dds-test.wellcomecollection.digirati.io/text* -> iiif-builder-text-stageprd         |
| 35       | dds-test.wellcomecollection.digirati.io/search* -> iiif-builder-text-stageprd       |
| 36       | iiif-test.wellcomecollection.org/text* -> iiif-builder-text-stageprd                |
| 37       | iiif-test.wellcomecollection.org/search* -> iiif-builder-text-stageprd              |
| 40       | dds.wellcomecollection.digirati.io/text* -> iiif-builder-text-prod                  |
| 41       | dds.wellcomecollection.digirati.io/search* -> iiif-builder-text-prod                |
| 42       | iiif.wellcomecollection.org/text* -> iiif-builder-text-prod                         |
| 43       | iiif.wellcomecollection.org/search* -> iiif-builder-text-prod                       |
| 60       | auth-test.wellcomecollection.digirati.io -> auth-test-stage                         |
| 200      | iiif.wellcomecollection.org -> iiif-builder-prod                                    |
| 210      | dds-stage.wellcomecollection.digirati.io -> iiif-builder-stage                      |
| 230      | dds-test.wellcomecollection.digirati.io -> iiif-builder-stageprd                    | 
| 240      | iiif-test.wellcomecollection.org -> iiif-builder-stageprd                           |
| 250      | iiif-stage.wellcomecollection.org -> iiif-builder-stage                             |
| 260      | dds.wellcomecollection.digirati.io -> iiif-builder-prod                             |

## Permissions

Assumed roles are used for accessing AWS. When using this Terraform, 2 profiles are needed as resources are used from different AWS accounts.

1. `main-wellcome` 
  - the 'main' Wellcome Cloud account. 
  - this is only used for accessing resources not in the main dlcs AWS account (`data "terraform_remote_state" "platform_infra"` resources).
2. `dev-wellcome` 
  - the profile that uses `main-wellcome` as source_profile to assume `digirati-developer` iam role. 
  - used for all resources in main dlcs AWS account (`provider`, `terraform` and other `data "terraform_remote_state"`).

> There may be other/better ways to achieve this!

