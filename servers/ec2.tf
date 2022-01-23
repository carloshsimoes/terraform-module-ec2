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
  iam_instance_profile = var.iam_instance_profile

  key_name      = var.key_name
  # public_key    = var.create_keypair ? tls_private_key.this.public_key_openssh : ""

  vpc_security_group_ids = var.enable_sg ? aws_security_group.optional[*].id : [data.aws_security_group.default.id]
  subnet_id     = var.subnet_id

  #associate_public_ip_address = true
  associate_public_ip_address = var.enable_eip

  root_block_device {
    volume_size = var.blocks_ebs_root_volume[0]
    volume_type = var.blocks_ebs_root_volume[1]
    encrypted   = true
  }

  dynamic "ebs_block_device" {
    for_each = var.blocks_ebs_volumes
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

resource "aws_eip" "servers" {
  count = var.enable_eip ? var.servers : 0
  instance = aws_instance.web[count.index].id
  vpc      = true
  depends_on = [aws_instance.web]
}