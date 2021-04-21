output "ip_address" {
  value = {
    for instance in aws_instance.web:
    instance.public_dns => instance.public_ip
  }
}