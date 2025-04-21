provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs = var.azs
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
}

module "ec2" {
  source = "./modules/ec2"
  subnet_id         = module.network.public_subnets[0]
  security_group_id = module.security.ec2_sg_id
  key_name          = var.key_name
}

module "rds" {
  source = "./modules/rds"
  db_subnet_ids     = module.network.private_subnets
  vpc_security_group_ids = [module.security.ec2_sg_id]
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}

module "alb" {
  source = "./modules/alb"
  public_subnets = module.network.public_subnets
  vpc_id         = module.network.vpc_id
  ec2_instance_id = module.ec2.instance_id
  alb_sg_id      = module.security.ec2_sg_id
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "alb_dns_name" {
  value = module.alb.dns_name
}
