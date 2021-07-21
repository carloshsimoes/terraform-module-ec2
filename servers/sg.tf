data "aws_security_group" "default" {

  filter {
    name   = "group-name"
    values = ["sgdefault"] 
  }

  tags = {
    modelo   = "sgdefault"
  }
}

resource "aws_security_group" "optional" {
  count = var.enable_sg ? 1 : 0
  name        = "allow-traffic-${var.name}"

  dynamic "ingress" {
    for_each = var.ingress
    content {
      from_port   = ingress.value["port_value"]
      to_port     = ingress.value["port_value"]
      protocol    = ingress.value["protocol_value"]
      cidr_blocks = [ingress.value["cidr_value"]]
    }
  }

  /*ingress { # Default ICMP
    from_port       = 8
    to_port         = 0
    protocol        = "icmp"
    cidr_blocks     = ["0.0.0.0/0"]
  }*/

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}