output "instance_arns" {
  value = {
    for instance in aws_instance.web :
    instance.id => instance.arn
  }
}

output "instance_private_ip" {
  value = {
    for instance in aws_instance.web :
    instance.id => instance.private_ip
  }
}

output "instance_public_ip" {
  value = {
    for instance in aws_instance.web :
    instance.id => instance.public_ip
  }
}

output "instance_public_dns" {
  value = {
    for instance in aws_instance.web :
    instance.id => instance.public_dns
  }
}

output "eip_public_ip" {
  value = {
    for eip in aws_eip.servers :
    eip.instance => eip.public_ip
  }
}

output "eip_public_dns" {
  value = {
    for eip in aws_eip.servers :
    eip.instance => eip.public_dns
  }
}
