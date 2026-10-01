resource "aws_cloudwatch_event_rule" "scan" {
  name                = "${local.name}-scan"
  description         = "Run the eBay opportunity scanner on a schedule"
  schedule_expression = var.scan_schedule
  state               = var.schedule_enabled ? "ENABLED" : "DISABLED"
}

resource "aws_cloudwatch_event_target" "scan" {
  rule     = aws_cloudwatch_event_rule.scan.name
  arn      = aws_ecs_cluster.app.arn
  role_arn = aws_iam_role.events.arn

  input = jsonencode({
    containerOverrides = [{
      name    = "app"
      command = ["python", "-m", "backend.scheduled_scan"]
    }]
  })

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.app.arn
    launch_type         = "FARGATE"
    task_count          = 1

    network_configuration {
      subnets          = aws_subnet.public[*].id
      security_groups  = [aws_security_group.task.id]
      assign_public_ip = true
    }
  }
}
