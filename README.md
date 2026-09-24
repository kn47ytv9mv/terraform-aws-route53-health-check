# terraform-aws-route53-health-check

Terraform module for a Route53 health check.

## Cost

A health check bills per check, per month — the rate depends on
`type` (endpoint checks cost more than calculated or CloudWatch-metric
checks) and `request_interval` (a 10-second interval costs more than the
default 30-second one). See AWS's
[Route53 pricing](https://aws.amazon.com/route53/pricing/#Health_Checks)
page for current rates.

## Design

This resource is genuinely one of four different shapes depending on
`type`, so this module mirrors AWS's own argument set directly — every
field is exposed, all optional, and it is on the caller to supply the
combination `type` needs (see the `type` row below) — the same
approach already used for `terraform-aws-alb-listener`'s `redirect`
block, rather than a type-discriminated redesign across four
genuinely different shapes.

Pass this module's `id` output to
[`terraform-aws-route53-record`](https://github.com/kn47ytv9mv/terraform-aws-route53-record)'s
`health_check_id` so an unhealthy endpoint drops out of latency, failover,
weighted, or any other routing policy automatically.

## Usage

```hcl
module "health_check" {
  source = "kn47ytv9mv/route53-health-check/aws"

  type          = "HTTPS"
  fqdn          = module.alb.dns_name
  port          = 443
  resource_path = "/health"
}
```

Or directly from this repository, a calculated check aggregating two
regional endpoint checks:

```hcl
module "health_check_global" {
  source = "github.com/kn47ytv9mv/terraform-aws-route53-health-check"

  type                   = "CALCULATED"
  child_healthchecks     = [module.health_check_us_east_1.id, module.health_check_eu_west_1.id]
  child_health_threshold = 1
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.9 |
| aws | ~> 6.61 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| type | Health check type: `'HTTP'`, `'HTTPS'`, `'HTTP_STR_MATCH'`, `'HTTPS_STR_MATCH'`, `'TCP'` (endpoint checks — need `fqdn` or `ip_address`), `'CALCULATED'` (needs `child_healthchecks` and `child_health_threshold`), `'CLOUDWATCH_METRIC'` (needs `cloudwatch_alarm_name` and `cloudwatch_alarm_region`), or `'RECOVERY_CONTROL'` (needs `routing_control_arn`). | `null` | no |
| fqdn | Domain name of the endpoint to check, for an endpoint check type. Either `fqdn` or `ip_address` is required for those types. | `null` | no |
| ip_address | IP address of the endpoint to check, for an endpoint check type. Either `fqdn` or `ip_address` is required for those types. | `null` | no |
| port | Port on the endpoint to check, for an endpoint check type. | `null` | no |
| resource_path | Path AWS requests on the endpoint, for an endpoint check type (e.g. `'/health'`). | `null` | no |
| search_string | String the response body must contain to be considered healthy, for the `'HTTP_STR_MATCH'`/`'HTTPS_STR_MATCH'` types. | `null` | no |
| request_interval | Seconds between health checks (`10` or `30`). If null, AWS's own default applies. Cannot be changed after creation. | `null` | no |
| failure_threshold | Number of consecutive failed checks before AWS considers the endpoint unhealthy. If null, AWS's own default applies. | `null` | no |
| measure_latency | Whether to measure latency and publish it as a CloudWatch metric, for an endpoint check type. | `null` | no |
| invert_healthcheck | Whether to invert the health check's status — treat a healthy result as unhealthy and vice versa. | `null` | no |
| enable_sni | Whether SNI is sent when performing the health check, for the `'HTTPS'`/`'HTTPS_STR_MATCH'` types. If null, AWS defaults to true for those types. | `null` | no |
| regions | AWS regions to perform the health check from, for an endpoint check type. If null, AWS checks from its own default set of regions. | `null` | no |
| disabled | Whether the health check is disabled — stops health checking, and any Route53 record depending on it is treated as healthy while disabled. | `null` | no |
| child_healthchecks | IDs of the health checks this one aggregates, for the `'CALCULATED'` type. | `null` | no |
| child_health_threshold | Minimum number of `child_healthchecks` that must be healthy for this `'CALCULATED'` check to be considered healthy. | `null` | no |
| cloudwatch_alarm_name | The name of the CloudWatch alarm to check, for the `'CLOUDWATCH_METRIC'` type. | `null` | no |
| cloudwatch_alarm_region | Region of the CloudWatch alarm to check, for the `'CLOUDWATCH_METRIC'` type. | `null` | no |
| insufficient_data_health_status | Status to use when the CloudWatch alarm has insufficient data (`'Healthy'`, `'Unhealthy'`, or `'LastKnownStatus'`), for the `'CLOUDWATCH_METRIC'` type. | `null` | no |
| routing_control_arn | The ARN of the Route53 Application Recovery Controller routing control to check, for the `'RECOVERY_CONTROL'` type. | `null` | no |
| reference_name | A name to identify this health check in the AWS console. Not the same as a Route53 record name — purely a label. | `null` | no |
| tags | A map of tags to assign to the health check. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the health check. Pass this to `terraform-aws-route53-record`'s `health_check_id`, or to another health check's `child_healthchecks` for a `CALCULATED` check. |
| arn | The ARN of the health check. |

## License

MIT — see [LICENSE.md](LICENSE.md).
