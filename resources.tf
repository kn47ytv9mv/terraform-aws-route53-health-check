resource "aws_route53_health_check" "resource" {
  type = var.type

  fqdn       = var.fqdn
  ip_address = var.ip_address
  port       = var.port

  resource_path = var.resource_path
  search_string = var.search_string

  request_interval  = var.request_interval
  failure_threshold = var.failure_threshold

  measure_latency    = var.measure_latency
  invert_healthcheck = var.invert_healthcheck
  enable_sni         = var.enable_sni
  regions            = var.regions
  disabled           = var.disabled

  child_healthchecks     = var.child_healthchecks
  child_health_threshold = var.child_health_threshold

  cloudwatch_alarm_name           = var.cloudwatch_alarm_name
  cloudwatch_alarm_region         = var.cloudwatch_alarm_region
  insufficient_data_health_status = var.insufficient_data_health_status

  routing_control_arn = var.routing_control_arn

  reference_name = var.reference_name

  tags = merge(var.tags, { name = "health-check" })
}

output "id" {
  description = "The ID of the health check. Pass this to terraform-aws-route53-record's health_check_id, or to another health check's child_healthchecks for a CALCULATED check."
  value       = aws_route53_health_check.resource.id
}

output "arn" {
  description = "The ARN of the health check."
  value       = aws_route53_health_check.resource.arn
}
