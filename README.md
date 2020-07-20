# iiif-builder-infrastructure

Terraform infrastructure for [IIIF-Builder](https://github.com/wellcomecollection/iiif-builder) application.

Current Terraform version: 0.12.x

> Note: Networking infrastructure (VPC + Subnets) are managed in the central [platform-infrastructure](https://github.com/wellcomecollection/platform-infrastructure/) repository.

> Note: S3 access to Wellcome buckets `wellcomecollection-storage` and `wellcomecollection-staging-storage` will need symmetric permissions in [storage-services](https://github.com/wellcomecollection/storage-service/).

## Table of Contents

* [common](/infrastructure/common/readme.md)
  * Terraform that is not for any particular environment.
* [modules](/infrastructure/modules)
  * A collection of reusable modules for creating groups of resources.
* [staging](/infrastructure/staging)
  * References _common_ and adds resources specific to the Staging environment.
