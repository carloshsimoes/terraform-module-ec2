variable "servers" {
  type = number
  default = 1
  description = "Quantidade instancias EC2 a lançar"
}

variable "so" {
  type = string
  default = "amazonlinux"
  description = "Tipo de SO Linux, ubuntu ou amazonlinux"
}

variable "iam_instance_profile" {
  type = string
  default = ""
  description = "ARN da Role que a instancia vai assumir"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
  description = "Tipo de instancia e familia a ser lançada"

  validation {
    # Opcao caso deseje condicionar a familia T (ex t2.micro ou t3.medium) por exemplo
    #condition     = length(var.instance_type) > 3 && substr(var.instance_type, 0, 1) == "t"
    #error_message = "O valor instance_type deve ser da família T, exemplo \"t2.micro\" ou \"t3.medium\"."
    condition     = length(var.instance_type) > 3
    error_message = "O valor instance_type deve ter no minimo 3 caracteres, exemplo \"t2.micro\" ou \"t3.medium\"."
  }

}

variable "name" {
  type        = string
  description = "Nome da instancia"
}

variable "environment" {
  type        = string
  default     = "staging"
  description = "Environment para definir TAG"
}

variable "create_keypair" {
  type    = bool
  default = false
  description = "Criar nova KeyPair para acesso a EC2"
}

variable "key_name" {
  type        = string
  description = "Nome da chave para conectar as EC2"
  default = ""
}

variable "blocks_ebs_root_volume" {
  type = list(string)
  default = ["8","gp3"]
  description = "Lista com valores para criação do volume root"
}

variable "blocks_ebs_volumes" {
  type = list(object({
    device_name = string
    volume_size = string
    volume_type = string
  }))
  description = "Lista com objetos Blocks para criação de volumes EBS adicionais"
  default = null
}

variable "enable_sg" {
  type    = bool
  default = false
  description = "Habilitar funcionalidade de criação do SG"
}

variable "enable_eip" {
  type    = bool
  default = false
  description = "Associar a um Elastic IP - Ip público fixo?"
}

variable "ingress" {
  type = list(object({
    port_value = number
    cidr_value = string
    protocol_value = string
  }))
  description = "Lista com objetos, rules, para criação das regras de inbound do resource SG"
}

variable "vpc_id" {
    type = string
    default = ""
    description = "Qual a VPC?"

    validation {
    condition     = length(var.vpc_id) > 3 && substr(var.vpc_id, 0, 4) == "vpc-"
    error_message = "O valor vpc_id deve ter no minimo 4 caracteres, exemplo \"vpc-\"."
  }
}

variable "subnet_id" {
    type = string
    default = ""
    description = "Qual a Subnet no qual a instância será criada?"
}

variable "custom_tags" {
  type    = map
  default = {}
}

variable "base_tags" {
  type    = map
  default = {}
}