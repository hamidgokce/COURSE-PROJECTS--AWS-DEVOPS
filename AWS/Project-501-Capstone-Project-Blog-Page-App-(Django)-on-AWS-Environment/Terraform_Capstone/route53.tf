resource "aws_route53_record" "aws_capstone_failover_record_1" {
  name = local.web_site_name
  type = "A"
  zone_id = local.zone_id
  depends_on = [aws_cloudfront_distribution.alb_distribution]

  failover_routing_policy {
    type = "PRIMARY"
  }
  set_identifier = "aws_capstone_failover_record1"
  health_check_id = aws_route53_health_check.primary.id
  alias {
    name                   = aws_cloudfront_distribution.alb_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.alb_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "aws_capstone_failover_record_2" {
  name = local.web_site_name
  type = "A"
  zone_id = local.zone_id
  depends_on = [aws_s3_bucket.aws_capstone_bucket_failover]
  failover_routing_policy {
    type = "SECONDARY"
  }
  set_identifier = "aws_capstone_failover_record2"
  alias {
    name                   = aws_s3_bucket.aws_capstone_bucket_failover.website_endpoint
    zone_id                = aws_s3_bucket.aws_capstone_bucket_failover.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_health_check" "primary" {
  fqdn              = local.web_site_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "cloudfront-health-check"
  }
}