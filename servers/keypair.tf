resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  create              = var.create_keypair
  key_name           = var.key_name
  public_key         = trimspace(tls_private_key.this.public_key_openssh)

  tags = {
    Name = var.key_name
    Env  = var.environment
  }

}

resource "local_file" "private_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = "${var.key_name}.pem"
  file_permission = "0600"
}