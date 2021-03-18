# DNS / ALB rules for dlcs.io (will eventually be deleted)

# pdf
resource "aws_alb_listener_rule" "pdf_dlcs_io" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 22

  action {
    type             = "forward"
    target_group_arn = module.pdf_generator.service_target_group_arn
  }

  condition {
    host_header {
      values = ["pdf.${local.domain}"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_route53_record" "pdf_dlcs_io" {
  zone_id = data.aws_route53_zone.external.id
  name    = "pdf.${local.domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.common.outputs.lb_fqdn
    zone_id                = data.terraform_remote_state.common.outputs.lb_zone_id
    evaluate_target_health = false
  }
}

# dashboard
resource "aws_alb_listener_rule" "dashboard_dlcs_io" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 12

  action {
    type             = "forward"
    target_group_arn = module.dashboard.service_target_group_arn
  }

  condition {
    host_header {
      values = ["dds.${local.domain}"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_route53_record" "dashboard_dlcs_io" {
  zone_id = data.aws_route53_zone.external.id
  name    = "dds.${local.domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.common.outputs.lb_fqdn
    zone_id                = data.terraform_remote_state.common.outputs.lb_zone_id
    evaluate_target_health = false
  }
}


# iiif-builder
resource "aws_alb_listener_rule" "iiif_builder_dlcs_io" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 11

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif.${local.domain}"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_route53_record" "iiif_builder_dlcs_io" {
  zone_id = data.aws_route53_zone.external.id
  name    = "iiif.${local.domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.common.outputs.lb_fqdn
    zone_id                = data.terraform_remote_state.common.outputs.lb_zone_id
    evaluate_target_health = false
  }
}