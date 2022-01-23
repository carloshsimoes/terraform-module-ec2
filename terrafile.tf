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
    encrypt = true
  }
}
*/

module "servers" {
  source         = "git::ssh://git@github.com:carloshsimoes/terraform-module-ec2//servers"
  
  # Caso baixe o repo localmente, pode especificar o source o path do mesmo, exemplo:
  #source        = "./servers"

  # Quantidade de instâncias a criar
  servers       = 1

  # Qual o distribuicao, ubuntu ou amazonlinux
  so            = "ubuntu"
  #so            = "amazonlinux"

  # Qual a familia/tipo da instância
  instance_type = "t2.micro"

   # Nome da instância
  name          = "srv-web"

  # Ambiente
  environment   = "Desenvolvimento"
  
  # Criar uma nova KeyPair utilizada para conectar a ec2
  create_keypair = true
  key_name      = "KP-EC2-NAME"

  # Role IAM associada a Instancia (Obs; Deve existir/ser criada previamente com repo de IAM)
  iam_instance_profile = "IAM_EC2_ROLE"

  # VPC onde o SG será criado
  vpc_id = "vpc-XXXXXXXXXXXXXX"

  # Subnet aonde a instancia sera criada
  # Privada
  #subnet_id = "subnet-XXXXXXXXXXXXXX"
  # Publica
  subnet_id = "subnet-XXXXXXXXXXXXXX"

  # Habilitar/Associar a Elastic IP - EIP?
  enable_eip = true
  #enable_eip = false

 # Volumes EBS especificações
  blocks = [
    {
      device_name = "/dev/sda1"
      volume_size = 10
      volume_type = "gp3"
    },
    #{
    #  device_name = "/dev/sdh"
    #  volume_size = 8
    #  volume_type = "gp2"
    #},
  ]

  # Habilitar/criar SG customizado?
  enable_sg = true
  #enable_sg = false

  # especificações do SG customizado, somente será criado se definido enable_sg = true
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
    /*{
      port_value     = 0
      cidr_value     = "10.16.0.0/16"
      protocol_value = -1
    },*/
  ]
}

# output "ip_address" {
#   value = module.servers.ip_address
# }