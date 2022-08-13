# data "aws_security_group" "default" {

#   filter {
#     name   = "group-name"
#     values = ["sgdefault"] 
#   }
  

#   tags = {
#     modelo   = "sgdefault"
#   }
# }


resource "aws_security_group" "default" {
  count = var.enable_sg ? 0 : 1
  name        = "sgdefault-${var.name}"
  vpc_id      = length(var.vpc_id) > 3 && substr(var.vpc_id, 0, 4) == "vpc-" ? var.vpc_id : data.aws_vpc.vpc_default.id

  # ingress {
  #   from_port       = 80
  #   to_port         = 80
  #   protocol        = "tcp"
  #   cidr_blocks     = ["0.0.0.0/0"]
  # }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgdefault-${var.name}"
    Env  = var.environment
  }

}

resource "aws_security_group" "optional" {
  count = var.enable_sg ? 1 : 0
  name        = "allow-traffic-${var.name}"
  vpc_id      = length(var.vpc_id) > 3 && substr(var.vpc_id, 0, 4) == "vpc-" ? var.vpc_id : data.aws_vpc.vpc_default.id

  dynamic "ingress" {
    for_each = var.ingress
    content {
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol_value"]
      cidr_blocks = [ingress.value["cidr_value"]]
    }
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-traffic-${var.name}"
    Env  = var.environment
  }

}