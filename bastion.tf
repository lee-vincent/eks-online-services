

resource "aws_security_group" "wg1_ingress_bastion" {
  name_prefix = "wg1_ingress_bastion"
  description = "worker group 1 bastion access"
  vpc_id      = module.vpc.vpc_id
}

# data "http" "workstation-external-ip" {
#   url = "http://ipv4.icanhazip.com"
# }


resource "aws_security_group_rule" "wg1_ingress_bastion" {
  description              = "allow bastion to access worker group 1 in private subnet."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.wg1_ingress_bastion.id
  source_security_group_id = aws_security_group.bastion_dmz.id
  from_port                = 22
  to_port                  = 22
  type                     = "ingress"
}


resource "aws_security_group" "bastion_dmz" {
  name_prefix = "bastion_dmz_"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      var.workstation_cidr
    ]
  }

  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.wg1_ingress_bastion.id]
  }
  tags = {
    Name = "bastion_dmz"
  }
}

resource "aws_instance" "bastion_instance" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.small"
  key_name                    = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  security_groups             = [aws_security_group.bastion_dmz.id]
  tags = {
    bastion = "true"
  }
}

# Get Amazon Linux AMI ID using SSM Parameter endpoint in us-east-1

data "aws_ssm_parameter" "amazon_linux_2_ami_us_east_1" {
  provider = aws.region-master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ami" "amazon_linux_2" {
  // us-east-1 = ami-038f1ca1bd58a5790
  // us-east-2 = ami-07a0844029df33d7d
  // us-west-1 = ami-0c7945b4c95c0481c
  // us-west-2 = ami-00f9f4069d04c0c6e

  // want to use filters so we use the correct
  // ami for the region
  most_recent = true
  owners      = ["137112412989"] # Amazon
  name_regex  = "^amzn2-ami-hvm-2.0.*.-x86_64-gp2"

  filter {
    name   = "is-public"
    values = ["true"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }


  filter {
    name   = "state"
    values = ["available"]
  }


  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = var.bastion_key
}



