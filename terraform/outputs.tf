output "ecr_repository_url" {
  description = "ECR repository used for application images."
  value       = aws_ecr_repository.app.repository_url
}

output "application_url" {
  description = "Public application URL (HTTP only in this portfolio deployment)."
  value       = "http://${aws_lb.app.dns_name}"
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.app.name
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.app.arn
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.app.name
}

output "eventbridge_rule_name" {
  value = aws_cloudwatch_event_rule.scan.name
}
