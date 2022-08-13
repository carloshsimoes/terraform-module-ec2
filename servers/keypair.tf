resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  count  = var.create_keypair ? 1 : 0
  source = "terraform-aws-modules/key-pair/aws"

  #create_key_pair    = var.create_keypair
  key_name           = var.key_name
  public_key         = tls_private_key.this.public_key_openssh
}