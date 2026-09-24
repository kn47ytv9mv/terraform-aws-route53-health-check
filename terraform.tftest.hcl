mock_provider "aws" {
}

run "type_invalid_rejected" {
  command = plan

  variables {
    type = "SIDEWAYS"
  }

  expect_failures = [var.type]
}

run "endpoint_type_without_fqdn_or_ip_address_rejected" {
  command = plan

  variables {
    type = "HTTPS"
  }

  expect_failures = [var.type]
}

run "calculated_type_without_child_fields_rejected" {
  command = plan

  variables {
    type = "CALCULATED"
  }

  expect_failures = [var.type]
}

run "cloudwatch_metric_type_without_alarm_fields_rejected" {
  command = plan

  variables {
    type = "CLOUDWATCH_METRIC"
  }

  expect_failures = [var.type]
}

run "recovery_control_type_without_routing_control_arn_rejected" {
  command = plan

  variables {
    type = "RECOVERY_CONTROL"
  }

  expect_failures = [var.type]
}

run "endpoint_check_fields_pass_through" {
  command = plan

  variables {
    type              = "HTTPS"
    fqdn              = "app.example.com"
    port              = 443
    resource_path     = "/health"
    request_interval  = 10
    failure_threshold = 3
    measure_latency   = true
  }

  assert {
    condition     = aws_route53_health_check.resource.type == "HTTPS"
    error_message = "type should pass through unchanged."
  }

  assert {
    condition     = aws_route53_health_check.resource.fqdn == "app.example.com"
    error_message = "fqdn should pass through unchanged."
  }

  assert {
    condition     = aws_route53_health_check.resource.request_interval == 10
    error_message = "request_interval should pass through unchanged."
  }
}

run "calculated_check_fields_pass_through" {
  command = plan

  variables {
    type                   = "CALCULATED"
    child_healthchecks     = ["abcd1234-ab12-cd34-ef56-abcdef123456", "dcba4321-cd21-ab43-fe65-654321fedcba"]
    child_health_threshold = 1
  }

  assert {
    condition     = length(aws_route53_health_check.resource.child_healthchecks) == 2
    error_message = "child_healthchecks should pass through unchanged."
  }

  assert {
    condition     = aws_route53_health_check.resource.child_health_threshold == 1
    error_message = "child_health_threshold should pass through unchanged."
  }
}

run "cloudwatch_metric_check_fields_pass_through" {
  command = plan

  variables {
    type                            = "CLOUDWATCH_METRIC"
    cloudwatch_alarm_name           = "app-5xx-errors"
    cloudwatch_alarm_region         = "us-east-1"
    insufficient_data_health_status = "Unhealthy"
  }

  assert {
    condition     = aws_route53_health_check.resource.cloudwatch_alarm_name == "app-5xx-errors"
    error_message = "cloudwatch_alarm_name should pass through unchanged."
  }

  assert {
    condition     = aws_route53_health_check.resource.insufficient_data_health_status == "Unhealthy"
    error_message = "insufficient_data_health_status should pass through unchanged."
  }
}

run "recovery_control_check_fields_pass_through" {
  command = plan

  variables {
    type                = "RECOVERY_CONTROL"
    routing_control_arn = "arn:aws:route53-recovery-control::123456789012:controlpanel/abcd1234ef5678901234567890abcdef/controlpanel/1234abcd5678ef9012345678901234ab"
  }

  assert {
    condition     = aws_route53_health_check.resource.routing_control_arn == "arn:aws:route53-recovery-control::123456789012:controlpanel/abcd1234ef5678901234567890abcdef/controlpanel/1234abcd5678ef9012345678901234ab"
    error_message = "routing_control_arn should pass through unchanged."
  }
}

run "readme_default_example" {
  command = plan

  variables {
    type          = "HTTPS"
    fqdn          = "app.example.com"
    port          = 443
    resource_path = "/health"
  }
}

run "readme_calculated_example" {
  command = plan

  variables {
    type                   = "CALCULATED"
    child_healthchecks     = ["abcd1234-ab12-cd34-ef56-abcdef123456", "dcba4321-cd21-ab43-fe65-654321fedcba"]
    child_health_threshold = 1
  }
}
