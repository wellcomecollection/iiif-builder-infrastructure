output "id" {
  value = aws_alb.lb.id
}

output "lb_zone_id" {
  value = aws_alb.lb.zone_id
}

output "lb_dns_name" {
  value = aws_alb.lb.dns_name
}

output "http_listener_arn" {
  value = aws_lb_listener.http_redirect.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}