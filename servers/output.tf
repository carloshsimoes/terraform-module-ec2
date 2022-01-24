output "private_ip" {
  value = {
    for instance in aws_instance.web:
    instance.private_ip => instance.private_ip
  }
}

output "public_dns" {
  value = {
    for instance in aws_instance.web:
    instance.public_dns => instance.public_dns
  }
}

output "public_ip" {
  value = {
    for instance in aws_instance.web:
    instance.public_ip => instance.public_ip
  }
}

output "id" {
  value = {
    for instance in aws_instance.web:
    instance.id => instance.id
  }
}

output "arn" {
  value = {
    for instance in aws_instance.web:
    instance.arn => instance.arn
  }
}

output "public_key" {
  value = {
    for key in tls_private_key.this:
    key.public_key => key.public_key
  }
}