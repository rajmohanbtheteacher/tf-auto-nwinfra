#This is root main.tf, don't modify this file, unless you have modified the modules

module "vpcs" {
  for_each = var.vpcs

  source                  = "./modules/vpc"
  name                    = each.key
  cidr_block              = each.value.cidr_block
  azs                     = var.azs
  create_internet_gateway = each.key == "Gateway-VPC" ? true : false
  create_nat_gateway      = each.key == "Gateway-VPC" ? true : false
  create_public_subnet    = each.key == "Gateway-VPC" ? true : false
}

module "transit_gateway" {
  source = "./modules/tgw"
  vpcs = {
    for k, v in module.vpcs : k => {
      vpc_id     = v.vpc_id
      subnet_ids = v.private_subnet_ids
    }
  }
}

resource "aws_route" "private_tgw_route" {
  for_each = module.vpcs

  route_table_id         = each.value.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.transit_gateway.transit_gateway_id
}

terraform {
  backend "s3" {
    bucket         = "become-techgeek-tfstate-demo"
    key            = "terraform/terraform.tfstate"  # (like a folder path)
    region         = "us-east-1"
    use_lock_table = "true"
    encrypt        = true
  }
}

