output "private_ip" {
  value = {
    for instance in aws_instance.web:
    instance.id => instance.private_ip
  }
}

output "public_dns" {
  value = {
    for instance in aws_instance.web:
    instance.id => instance.public_dns
  }
}

output "public_ip" {
  value = {
    for instance in aws_instance.web:
    instance.id => instance.public_ip
  }
}

output "arn" {
  value = {
    for instance in aws_instance.web:
    instance.id => instance.arn
  }
}
