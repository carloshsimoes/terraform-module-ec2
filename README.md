# Terraform / Module / Servers

Exemplo de código criado para criação de instâncias EC2 no Provider AWS!

**OBS:** Não esquecer de passar os parâmetros "AWS_ACCESS_KEY_ID" e "AWS_SECRET_ACCESS_KEY" de uma conta que possui permissões para performar/criar recursos no seu provider AWS, assim como consumir o S3 caso esteja utilizando state remoto!


Criar em sua conta AWS também, um Security Group (SG) default, com os atributos abaixo:

* Security Group Name: sgdefault
* TAG: key="modelo" / value="sgdefault"
* Inboud/Ingress (somente como base para padrão): tcp, 80, 0.0.0.0/0 


## Para consumir o modulo, você deverá passar os inputs:

* **servers (number)** -> Quantidade de instâncias a criar (ex: 1)
* **so (string)** -> Distribuição SO, ("ubuntu" ou "amazonlinux"), no qual o modulo vai buscar a AMI oficial correspondente na sua última versão!
* **instance_type (string)** -> Tipo de instância a ser criada, exemplo "t2.micro".
* **name (string)** -> Nome da sua ou suas instâncias, exemplo: "srv-web-dev"
* **environment (string)** -> Qual o ambiente? Será criada uma TAG também com esse atributo, identificando o environment, exemplo: "Desenvolvimento"
* **create_keypair (bool)** -> Deseja criar a KeyPair (PrivateKey) para acesso a instância EC2 automaticamente? True | False
* **key_name (string)** -> Private Key utilizada para conectar a instância EC2
* **iam_instance_profile (string)** -> Role IAM associada a Instancia (Obs; Deve existir/ser criada previamente com repo de IAM)
* **vpc_id (string)** -> Qual a VPC os recursos serão criados? exemplo "vpc-03b0a419b5b2e9e2e".
* **subnet_id (string)** -> Qual a Subnet os recursos serão criados? exemplo subnet-02c7ceb2a5feafd40".
* **root_block_device (list object)** -> Definições de volume ROOT a ser criado. * Veja exemplo no "terrafile.tf" abaixo!
* **ebs_block_device (list object)** -> Definições de volumes EBS adicionais a serem criados. * Veja exemplo no "terrafile.tf" abaixo!
* **enable_sg (bool)** -> Deseja criar um Security Group (SG) customizado? True | False
* **enable_eip (bool)** -> Deseja criar e associar um Elastic IP (IP)? True | False
* **ingress (list object))** - > Definições do SG a ser criado, caso tenha habilitado a flag "enable_sg"


## Veja exemplo no "terrafile.tf" abaixo:

Para usar o modulo, criar no módulo raiz (root module) o arquivo **terrafile.tf**, conforme o exemplo abaixo:


```terraform
provider "aws" {
  #region  = "us-east-1" #Virginia
  region  = "sa-east-1" #SaoPaulo
  version = "~> 3.0"
}

# Caso use/queira usar state remoto em um bucket S3

/*
terraform {
  backend "s3" {
    # Lembre de trocar o bucket para o seu Bucket S3 e também a região do Bucket!!
    bucket  = "nome-meubucket-tfstate"
    key     = "terraform-ec2-instances.tfstate"
    region  = "sa-east-1" #SaoPaulo
    #region  = "us-east-1" #Virginia
    encrypt = true
  }
}
*/

module "servers" {
  source = "git::https://github.com/carloshsimoes/terraform-module-ec2//servers"

  # Quantidade de instâncias a criar
  servers = 1

  # Qual o distribuicao, ubuntu ou amazonlinux
  so = "ubuntu"
  #so            = "amazonlinux"

  # Qual a familia/tipo da instância
  instance_type = "t2.micro"

  # Nome da instância
  name = "nome-da-minha-instancia"

  # Ambiente
  environment = "Producao"

  # Criar uma nova KeyPair utilizada para conectar a ec2
  create_keypair = true
  key_name       = "KP-EC2-NOME-CHAVE-PRIVADA"

  # Role IAM associada a Instancia (Obs; Deve existir/ser criada previamente com repo de IAM)
  iam_instance_profile = "EC2-Role-Name"

  # VPC onde o SG será criado
  vpc_id = "vpc-xxxxxxxxxxxxxxxxx"

  # Subnet aonde a instancia sera criada
  subnet_id = "subnet-xxxxxxxxxxxxxxxxx"

  # Habilitar/Associar a Elastic IP - EIP?
  enable_eip = true
  #enable_eip = false

  # Volume EBS ROOT | Tamanho, tipo
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 30
      encrypted   = true
    },
  ]

  # Volumes EBS Adicionais especificações
  #ebs_block_device = [
  #  {
  #    device_name = "/dev/sdg"
  #    volume_size = 50
  #    volume_type = "gp3"
  #    encrypted   = true
  #  },
  #  {
  #   device_name = "/dev/sdh"
  #   volume_size = 50
  #   volume_type = "gp2"
  #   encrypted   = true
  #  },
  #]

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

output "id" {
  value = module.servers.id
}

output "arn" {
  value = module.servers.arn
}

output "private_ip" {
  value = module.servers.private_ip
}

output "public_dns" {
  value = module.servers.public_dns
}

output "public_ip" {
  value = module.servers.public_ip
}
```

