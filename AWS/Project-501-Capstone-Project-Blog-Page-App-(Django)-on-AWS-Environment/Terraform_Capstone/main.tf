provider "aws" {
  region = local.region
  profile = local.aws_profile
}

locals {
  name              = "aws_capstone_project" # write your project name
  aws_profile       = "clarusway_training" # write your aws profile. If you do not have any profile please write here as default
  bucket_name       = "awscapstoneserdar" # write your bucket name used by Django application
  region            = "us-east-2" # write your region
  web_site_name     = "www.clarusway.us" # write your subdomain
  zone_id           = "Z08348542LMKDSH94CCW6" #write your route53 zone id which belongs your domain name
  certificate_arn_alb   = "XXXXXXXXXXXXX" # write your certficate arn for https secure connection used by ALB
  certificate_arn_cloudfront = "XXXXXXXXXXXXXXXXXXXX"
  # write your certficate arn for https secure connection used by Cloudfront. Be careful!!! Even though you create this stack any region except us-east-1, Cloudfront needs the certificate issued in us-east-1 region. Thts why, if you create this stack in us-east-1, you can use your certificate issued in this region, but if you create this stack in different region, you have to use a certificate isuued in us-east-1. 
  tags = {
    Name = local.name
  }
}