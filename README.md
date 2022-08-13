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
  region  = "us-east-1" #Virginia
  #region  = "sa-east-1" #SaoPaulo
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
  instance_type = "t3.micro"

  # Nome da instância
  name = "nome-da-minha-instancia"

  # Ambiente
  environment = "Producao"

  # Criar uma nova KeyPair utilizada para conectar a ec2
  create_keypair = true
  key_name       = "KP-EC2-NOME-CHAVE-PRIVADA"

  # Role IAM associada a Instancia (Obs; Deve existir/ser criada previamente com repo de IAM)
  #iam_instance_profile = "EC2-Role-Name"

  # VPC onde o SG será criado - Senão informar uma vai usar a "default"
  # Deve atender requisito: length(var.vpc_id) > 3 && substr(var.vpc_id, 0, 4) == "vpc-"
  # Caso contrario vai buscar/usar a vpc-default"

  #vpc_id = "vpc-xxxxxxxxxxxxxxxxx"


  # Subnet aonde a instancia sera criada
  # Deve atender requisito: length(var.subnet_id) > 6 && substr(var.subnet_id, 0, 7) == "subnet-"
  # Caso contrário vai passar NULL

  #subnet_id = "subnet-xxxxxxxxxxxxxxxxx"

  # Habilitar/Associar a Elastic IP - EIP?
  enable_eip = true
  #enable_eip = false

  # Volume EBS ROOT | Tamanho, tipo
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 10
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
      from_port     = 80
      to_port       = 80
      cidr_value     = "0.0.0.0/0"
      protocol_value = "tcp"
    },
    {
      from_port     = 443
      to_port       = 443
      cidr_value     = "0.0.0.0/0"
      protocol_value = "tcp"
    },
    {
      from_port     = 22
      to_port       = 22
      cidr_value     = "0.0.0.0/0"
      protocol_value = "tcp"
    },
    {
      from_port     = 8
      to_port       = 0
      cidr_value     = "0.0.0.0/0"
      protocol_value = "icmp"
    },
    /*
    {
      from_port     = 0
      to_port       = 0
      cidr_value     = "10.16.0.0/16"
      protocol_value = -1
    },
    */
  ]
}

output "instance_arns" {
  value = module.servers.instance_arns
}

output "instance_private_ip" {
  value = module.servers.instance_private_ip
}

output "instance_public_ip" {
  value = module.servers.instance_public_ip
}

output "instance_public_dns" {
  value = module.servers.instance_public_dns
}

output "eip_public_ip" {
  value = module.servers.eip_public_ip
}

output "eip_public_dns" {
  value = module.servers.eip_public_dns
}

```


# Utilizando o Docker para executar seu IaC

## Criando o container mapeando seu contexto/pasta atual para o container:

OBS; Como iremos criar nossos recursos na CLOUD AWS, você pode exportar/env previamente "AWS_ACCESS_KEY_ID" e "AWS_SECRET_ACCESS_KEY", em seguida repassando o mesmo na criação do Container.

```bash

docker container run -ti --env "AWS_ACCESS_KEY_ID" --env "AWS_SECRET_ACCESS_KEY" -v "$PWD:/app" -w /app --entrypoint "" hashicorp/terraform:light sh

```

# Executando seu PLAN e APPLY para criar seus recursos:

Já dentro do nosso container, estaremos na pasta "/app" que é nosso "workdir", na qual montando (BIND).

Logo, uma vez criado nosso arquivo de definição `terrafile.tf` como no exemplo acima na DOC, basta executar nosso PLAN e APPLY:


```bash

terraform plan -out plano

```


Valide seus recursos se estão conforme definido. Estando tudo ok, basta aplicar o estado:

```bash

terraform apply "plano"

```


E claro, não menos importante, para destruir tudo:

```bash

terraform destroy

```


