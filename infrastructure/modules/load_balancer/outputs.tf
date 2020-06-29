output "id" {
  value = aws_alb.lb.id
}

output "http_listener_arn" {
  value = aws_lb_listener.http_redirect.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}