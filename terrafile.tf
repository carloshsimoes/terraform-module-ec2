provider "aws" {
  region  = "us-east-1" #Virginia
  version = "~> 3.0"
}

# Caso use/queira usar state remoto em um bucket S3
/*
terraform {
  backend "s3" {
    # Lembre de trocar o bucket para o seu Bucket S3 e também a região do Bucket!!
    bucket = "nome-meu-bucket-terraformstate"
    key    = "terraform-lab.tfstate"
    region = "us-east-1" #virginia
  }
}
*/

module "servers" {
  #source         = "git@github.com:carloshsimoes/terraform-module-ec2"
  source        = "./servers"
  servers       = 1
  so            = "ubuntu"
  instance_type = "t2.micro"
  name          = "srv-web"
  environment   = "Desenvolvimento"

  blocks = [
    {
      device_name = "/dev/sdg"
      volume_size = 8
      volume_type = "gp2"
    },
    {
      device_name = "/dev/sdh"
      volume_size = 2
      volume_type = "gp2"
    },
  ]

  enable_sg = true

  ingress = [
    {
      port_value     = 80
      cidr_value     = "0.0.0.0/0"
      protocol_value = "tcp"
    },
    {
      port_value     = 443
      cidr_value     = "0.0.0.0/0"
      protocol_value = "tcp"
    },
    {
      port_value     = 22
      cidr_value     = "0.0.0.0/0"
      protocol_value = "tcp"
    },
  ]
}

output "ip_address" {
  value = module.servers.ip_address
}