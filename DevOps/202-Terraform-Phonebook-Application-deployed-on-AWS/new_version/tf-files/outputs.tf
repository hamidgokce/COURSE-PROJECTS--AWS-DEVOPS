output "dns-name" {
  value = "http://${aws_alb.app-lb.dns_name}"
}

# output "websiteurl" {
#     value = aws_route53_record.phonebook.name
# }

output "my-subnet" {
  value = data.aws_subnets.pb-subnets.ids

}

output "my-ami" {
  value = data.aws_ami.amazon-linux-2.id
}