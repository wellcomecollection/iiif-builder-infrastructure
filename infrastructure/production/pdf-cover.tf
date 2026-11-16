# PDF cover pages are served by the DDS server (iiif-builder's PdfCoverController), which replaced the
# Python pdf-generator service. The DLCS's pdf named query asks for
# https://iiif.wellcomecollection.org/pdf-cover/{id}; Wellcome's CloudFront sends /pdf-cover* to
# pdf.wellcomecollection.digirati.io, so that hostname now forwards to iiif-builder instead.
# The listener rule and DNS record used to belong to module.pdf_generator; the moved blocks keep them,
# so this is an in-place change of target, with no gap and no priority clash.

moved {
  from = module.pdf_generator.aws_alb_listener_rule.https[0]
  to   = aws_alb_listener_rule.pdf_cover
}

moved {
  from = module.pdf_generator.aws_route53_record.service[0]
  to   = aws_route53_record.pdf_cover
}

# pdf.wellcomecollection.digirati.io/pdf-cover* -> iiif-builder
resource "aws_alb_listener_rule" "pdf_cover" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 25

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder.service_target_group_arn
  }

  condition {
    host_header {
      values = ["pdf.${data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io}"]
    }
  }

  condition {
    path_pattern {
      values = ["/pdf-cover*"]
    }
  }
}

resource "aws_route53_record" "pdf_cover" {
  zone_id = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io_zone_id
  name    = "pdf.${data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.common.outputs.lb_fqdn
    zone_id                = data.terraform_remote_state.common.outputs.lb_zone_id
    evaluate_target_health = false
  }
}
