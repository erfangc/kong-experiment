provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name = "kong-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_key_pair" "keypair" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCdi2kMMLUQ0uotL+Hp2rvSjsIhH7XOd+22vDP5F20FjzjU3/tvn5hFp5HP4UFmNc1ojggsZWWWpOqH0jQlL01+8OJ8poxJdxnUHNggqExCA7C1Bfl8pJs7U/i45JVZRCXVoYUdE701YtbeSqu3sXG/q3eWwKaOVS5FTUovaANGjQNXJwa/2nXemN615LwksdbwCGIT9zOBNXem9o1lGCycNOoyw0aR88y7S+PYdq4081CP0tGxGMG15zw25XRAqAL/2jMo2Rg9jY3k5rVulyvqv1I15qRplPFVIPJPbFTub85a8v7JR0H8jnaEt5na/42t5JhcWMGN0tKH5R6cDbtpyss2z842mZpuH8MTYHxst9ARt3boL+Co5roBMhhuguMclgI3a0XGq/hPRkM8bB/Ak+dIHcD4gxMpAqNPoJMZXDttMQq/iRUNtheB25HKgLj3HnYj+O9L+LleVn1ZKGY+dZ7H72CXvoavVj/YTj/ju/TGxO6d1/sMlJU0HYErD4XKJc49goBtukac+csrfircUTCFj8PSPJrjdu9+F43dqCZXr9FKaDGlX+zs4y9+8J1OznIcPQWYZ4rdjdPOs+e/EFZ1jYlcuqfRhrm3h524oT48ECz4b6LBFeWAxVv+P/962AMhX0k++54GnII6thtCChg9I4egYIVOovvdZHPAJQ== your_email@example.com"
  key_name   = "macbook_pro"
}

resource "aws_instance" "kong" {
  ami                    = "ami-0dfcb1ef8550277af" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type          = "t3.medium"
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = aws_key_pair.keypair.key_name
  vpc_security_group_ids = [aws_security_group.kong.id]
  user_data              = <<EOF
                #!/bin/bash
                curl -Lo kong-enterprise-edition-3.1.1.3.aws.amd64.rpm "https://download.konghq.com/gateway-3.x-amazonlinux-2/Packages/k/kong-enterprise-edition-3.1.1.3.aws.amd64.rpm"
                yum install -y kong-enterprise-edition-3.1.1.3.aws.amd64.rpm
                chown -R ec2-user:ec2-user /usr/local/kong
                EOF
  root_block_device {
    volume_size = 20
  }
}

resource "aws_security_group" "kong" {
  name   = "kong"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = aws_instance.kong.public_ip
}
