output "instance_arns" {
  value = {
    for instance in aws_instance.web :
    instance.id => instance.arn
  }
}

output "instances_public_address" {
  value = {
    for instance in aws_instance.web:
    instance.id => ["Public IP: ${instance.public_ip}, Public DNS: ${instance.public_dns}"]
  }
  
}

output "eip_public_address" {
  value = {
    for instance in aws_instance.web:
    eip.instance => ["Public IP: ${eip.public_ip}, Public DNS: ${eip.public_dns}"]
  }
  
}
