data "aws_vpc" "vpc_default" {
  default = true
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
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

  vpc_security_group_ids = var.enable_sg ? aws_security_group.optional[*].id : [data.aws_security_group.default.id]

  #subnet_id     = var.subnet_id
  subnet_id      = length(var.subnet_id) > 6 && substr(var.subnet_id, 0, 7) == "subnet-" ? var.subnet_id : null

  associate_public_ip_address = var.enable_eip

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
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