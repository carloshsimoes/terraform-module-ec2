# Terraform / Module / Servers

Exemplo de código criado para criação de instâncias EC2 no Provider AWS!

**OBS:** Não esquecer de passar os parâmetros "AWS_ACCESS_KEY_ID" e "AWS_SECRET_ACCESS_KEY" de uma conta que possui permissões para performar/criar recursos no seu provider AWS, assim como consumir o S3 caso esteja utilizando state remoto!


- Criar em sua conta AWS também, um Security Group (SG) default, com os atributos abaixo:

* Security Group Name: sgdefault
* TAG: key="modelo" / value="sgdefault"
* Inboud/Ingress (somente como base para padrão): tcp, 80, 0.0.0.0/0 


## Para consumir o modulo, você deverá passar os inputs:

* **servers (number)** -> Quantidade de instâncias a criar (ex: 1)
* **so (string)** -> Distribuição SO, ("ubuntu" ou "amazonlinux"), no qual o modulo vai buscar a AMI correspondendo oficial correspondente na sua última versão!
* **instance_type (string)** -> Tipo de instância a ser criada, exemplo "t2.micro".
* **name (string)** -> Nome da sua ou suas instâncias, exemplo: "srv-web-dev"
* **environment (string)** -> Qual o ambiente? Será criada uma TAG também com esse atributo, identificando o environment, exemplo: "Desenvolvimento"
* **blocks (list object)** -> Definições de volume(s) EBS a serem criados. * Veja exemplo no "terrafile.tf" abaixo!
* **enable_sg (bool)** -> Deseja criar um Security Group (SG) customizado? True | False
* **ingress (list object))** - > Definições do SG a ser criado, caso tenha habilitado a flag "enable_sg"


## Veja exemplo no "terrafile.tf" abaixo:

Para usar o modulo, criar no módulo raiz (root module) o arquivo **terrafile.tf**, conforme o exemplo abaixo:


```terraform
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
  source                  = "git@github.com:carloshsimoes/terraform-module-ec2?ref=1.0"
  servers       = 1
  so            = "ubuntu"
  instance_type = "t2.micro"
  name          = "srv-web-dev"
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
```

