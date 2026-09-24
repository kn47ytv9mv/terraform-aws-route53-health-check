variable "type" {
  default     = null
  description = "Health check type: 'HTTP', 'HTTPS', 'HTTP_STR_MATCH', 'HTTPS_STR_MATCH', 'TCP' (endpoint checks — need fqdn or ip_address), 'CALCULATED' (needs child_healthchecks and child_health_threshold), 'CLOUDWATCH_METRIC' (needs cloudwatch_alarm_name and cloudwatch_alarm_region), or 'RECOVERY_CONTROL' (needs routing_control_arn)."

  validation {
    condition = var.type == null || contains(
      ["HTTP", "HTTPS", "HTTP_STR_MATCH", "HTTPS_STR_MATCH", "TCP", "CALCULATED", "CLOUDWATCH_METRIC", "RECOVERY_CONTROL"],
      var.type
    )
    error_message = "type must be one of 'HTTP', 'HTTPS', 'HTTP_STR_MATCH', 'HTTPS_STR_MATCH', 'TCP', 'CALCULATED', 'CLOUDWATCH_METRIC', or 'RECOVERY_CONTROL'."
  }

  validation {
    condition = var.type == null ? true : (
      contains(["HTTP", "HTTPS", "HTTP_STR_MATCH", "HTTPS_STR_MATCH", "TCP"], var.type) ? (var.fqdn != null || var.ip_address != null) :
      var.type == "CALCULATED" ? (var.child_healthchecks != null && var.child_health_threshold != null) :
      var.type == "CLOUDWATCH_METRIC" ? (var.cloudwatch_alarm_name != null && var.cloudwatch_alarm_region != null) :
      var.type == "RECOVERY_CONTROL" ? (var.routing_control_arn != null) :
      true
    )
    error_message = "type's required companion fields are missing: an endpoint type (HTTP/HTTPS/HTTP_STR_MATCH/HTTPS_STR_MATCH/TCP) needs fqdn or ip_address; CALCULATED needs child_healthchecks and child_health_threshold; CLOUDWATCH_METRIC needs cloudwatch_alarm_name and cloudwatch_alarm_region; RECOVERY_CONTROL needs routing_control_arn."
  }
}

variable "fqdn" {
  default     = null
  description = "Domain name of the endpoint to check, for an endpoint check type. Either fqdn or ip_address is required for those types."
}

variable "ip_address" {
  default     = null
  description = "IP address of the endpoint to check, for an endpoint check type. Either fqdn or ip_address is required for those types."
}

variable "port" {
  default     = null
  description = "Port on the endpoint to check, for an endpoint check type."
}

variable "resource_path" {
  default     = null
  description = "Path AWS requests on the endpoint, for an endpoint check type (e.g. '/health')."
}

variable "search_string" {
  default     = null
  description = "String the response body must contain to be considered healthy, for the 'HTTP_STR_MATCH'/'HTTPS_STR_MATCH' types."
}

variable "request_interval" {
  default     = null
  description = "Seconds between health checks (10 or 30). If null, AWS's own default applies. Cannot be changed after creation."
}

variable "failure_threshold" {
  default     = null
  description = "Number of consecutive failed checks before AWS considers the endpoint unhealthy. If null, AWS's own default applies."
}

variable "measure_latency" {
  default     = null
  description = "Whether to measure latency and publish it as a CloudWatch metric, for an endpoint check type."
}

variable "invert_healthcheck" {
  default     = null
  description = "Whether to invert the health check's status — treat a healthy result as unhealthy and vice versa."
}

variable "enable_sni" {
  default     = null
  description = "Whether SNI is sent when performing the health check, for the 'HTTPS'/'HTTPS_STR_MATCH' types. If null, AWS defaults to true for those types."
}

variable "regions" {
  default     = null
  description = "AWS regions to perform the health check from, for an endpoint check type. If null, AWS checks from its own default set of regions."
}

variable "disabled" {
  default     = null
  description = "Whether the health check is disabled — stops health checking, and any Route53 record depending on it is treated as healthy while disabled."
}

variable "child_healthchecks" {
  default     = null
  description = "IDs of the health checks this one aggregates, for the 'CALCULATED' type."
}

variable "child_health_threshold" {
  default     = null
  description = "Minimum number of child_healthchecks that must be healthy for this 'CALCULATED' check to be considered healthy."
}

variable "cloudwatch_alarm_name" {
  default     = null
  description = "The name of the CloudWatch alarm to check, for the 'CLOUDWATCH_METRIC' type."
}

variable "cloudwatch_alarm_region" {
  default     = null
  description = "Region of the CloudWatch alarm to check, for the 'CLOUDWATCH_METRIC' type."
}

variable "insufficient_data_health_status" {
  default     = null
  description = "Status to use when the CloudWatch alarm has insufficient data ('Healthy', 'Unhealthy', or 'LastKnownStatus'), for the 'CLOUDWATCH_METRIC' type."
}

variable "routing_control_arn" {
  default     = null
  description = "The ARN of the Route53 Application Recovery Controller routing control to check, for the 'RECOVERY_CONTROL' type."
}

variable "reference_name" {
  default     = null
  description = "A name to identify this health check in the AWS console. Not the same as a Route53 record name — purely a label."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the health check."
}
