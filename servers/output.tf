output "private_ip" {
  value = {
    for instance in aws_instance.web:
    instance => instance.private_ip
  }
}

output "public_dns" {
  value = {
    for instance in aws_instance.web:
    instance => instance.public_dns
  }
}

output "public_ip" {
  value = {
    for instance in aws_instance.web:
    instance => instance.public_ip
  }
}

output "id" {
  value = {
    for instance in aws_instance.web:
    instance => instance.id
  }
}

output "arn" {
  value = {
    for instance in aws_instance.web:
    instance => instance.arn
  }
}
