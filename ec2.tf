data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Ubuntu
}

data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-minimal-selinux-enforcing-hvm-*"]
  }

  owners = ["137112412989"] # Amazon
}

resource "aws_instance" "web" {
  count         = var.servers
  ami           = var.so == "ubuntu" ? data.aws_ami.ubuntu.id : data.aws_ami.amazonlinux.id
  instance_type = var.instance_type
  vpc_security_group_ids = var.enable_sg ? aws_security_group.optional[*].id : [data.aws_security_group.default.id]

  dynamic "ebs_block_device" {
    for_each = var.blocks
    content {
      device_name = ebs_block_device.value["device_name"]
      volume_size = ebs_block_device.value["volume_size"]
      volume_type = ebs_block_device.value["volume_type"]
    }
  }

  tags = {

    Name = var.name
    Env  = var.environment
  }
}