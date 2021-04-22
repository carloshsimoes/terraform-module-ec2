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

variable "blocks" {
  type = list(object({
    device_name = string
    volume_size = string
    volume_type = string
  }))
  description = "Lista com objetos Blocks para criação de volumes EBS"
}

variable "enable_sg" {
  type    = bool
  default = false
  description = "Habilitar funcionalidade de criação do SG"
}

variable "ingress" {
  type = list(object({
    port_value = number
    cidr_value = string
    protocol_value = string
  }))
  description = "Lista com objetos, rules, para criação das regras de inbound do resource SG"
}
