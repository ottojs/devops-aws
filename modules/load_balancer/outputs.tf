
output "listener_https" {
  value = aws_lb_listener.https
}

output "load_balancer" {
  value = aws_lb.main
}
