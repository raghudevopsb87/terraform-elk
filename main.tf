terraform {
  backend "s3" {
    bucket = "terraform-state-b87"
    key    = "elk/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}


resource "aws_instance" "elk" {
  ami = "ami-045a533d19c34eeb6"
  vpc_security_group_ids = [ "sg-09663d91a4fca31c9" ]
  instance_type = "r7iz.large"

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "persistent"
      instance_interruption_behavior = "stop"
    }
  }

  tags = {
    Name = "elk"
  }

}

resource "null_resource" "ansible" {
  triggers = {
    id = aws_instance.elk.id
  }

  provisioner "local-exec" {
    command = <<EOF
      ansible-playbook -i ${aws_instance.elk.private_ip}, elk.yml -e ansible_user=ec2-user -e ansible_password=DevOps321
EOF
  }

}