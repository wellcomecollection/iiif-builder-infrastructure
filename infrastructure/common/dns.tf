resource "aws_route53_zone" "wellcomecollection_digirati_io" {
  name = local.domain
}

# SSL Cert + Validation
resource "aws_acm_certificate" "cert" {
  domain_name       = local.domain
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${local.domain}",
    "*.dlcs.io",
    "dlcs.io",
  ]

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  ttl             = 300
  type            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  zone_id         = aws_route53_zone.wellcomecollection_digirati_io.zone_id
}

resource "aws_route53_record" "cert_validation_wildcard" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.cert.domain_validation_options)[1].resource_record_name
  records         = [tolist(aws_acm_certificate.cert.domain_validation_options)[1].resource_record_value]
  ttl             = 300
  type            = tolist(aws_acm_certificate.cert.domain_validation_options)[1].resource_record_type
  zone_id         = aws_route53_zone.wellcomecollection_digirati_io.zone_id
}

# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name    = dvo.resource_record_name
#       record  = dvo.resource_record_value
#       type    = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 300
#   type            = each.value.type
#   zone_id         = aws_route53_zone.wellcomecollection_digirati_io.zone_id
# }

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  #validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  validation_record_fqdns = [
    aws_route53_record.cert_validation.fqdn,
    aws_route53_record.cert_validation_wildcard.fqdn,
    "_351db1641ca318b8ac18a64f892ebaf4.dlcs.io"
  ]
}