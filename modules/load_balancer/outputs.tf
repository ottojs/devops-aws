
output "listener_https_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "security_group_id" {
  description = "ID of the load balancer security group"
  value       = aws_security_group.alb.id
}

output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL (if public load balancer)"
  value       = var.public && var.waf_enabled ? aws_wafv2_web_acl.main[0].id : null
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL (if public load balancer)"
  value       = var.public && var.waf_enabled ? aws_wafv2_web_acl.main[0].arn : null
}
