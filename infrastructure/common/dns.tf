resource "aws_route53_zone" "wellcomecollection_digirati_io" {
  name = local.domain
}

module "cert" {
  source = "github.com/wellcomecollection/terraform-aws-acm-certificate?ref=v1.0.0"

  domain_name = local.domain

  subject_alternative_names = [
    "*.${local.domain}"
  ]

  zone_id = aws_route53_zone.wellcomecollection_digirati_io.zone_id

  providers = {
    aws.dns = aws
  }
}
