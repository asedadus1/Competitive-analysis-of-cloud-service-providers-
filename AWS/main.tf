terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
  access_key = "=============="
  secret_key = "============================"
}

resource "aws_instance" "ec2_example" {
    ami = "ami-0776c814353b4814d"
    instance_type = "t2.micro" 
    key_name = "id_rsa"
    vpc_security_group_ids = [aws_security_group.main.id]

    provisioner "remote-exec" {
        inline = [
            #"touch hello.txt",
            #"echo helloworld remote provisioner >> hello.txt",
            "sudo apt-get update", 
            "sudo apt-get install -y sysbench", 
            "sysbench --test=cpu run", 
            "sysbench --test=memory run",
            "sysbench --test=fileio --file-test-mode=seqwr run"
        ]
    }

    connection {
        type        = "ssh"
        host        = self.public_ip
        user        = "ubuntu"
        private_key = file("/Users/tylerfelicidario/.ssh/id_rsa")
        timeout     = "4m"
    }

    tags = {
        Name = "Terraform EC2"
    }
}

resource "aws_security_group" "main" {
    egress = [
        {
            cidr_blocks      = [ "0.0.0.0/0", ]
            description      = ""
            from_port        = 0
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "-1"
            security_groups  = []
            self             = false
            to_port          = 0
        }
    ]
    ingress = [
        {
            cidr_blocks      = [ "0.0.0.0/0", ]
            description      = ""
            from_port        = 22
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "tcp"
            security_groups  = []
            self             = false
            to_port          = 22
        }
    ]
}

resource "aws_key_pair" "deployer" {
    key_name   = "id_rsa"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCu5XMp/GcYWsJe61toKt+HruXG11fVfBBeYftvTVditxD8mtdLft/261aKFYqC62cR5zkhiCABA8T4icVh5RkiDFkSaJMuw7+yvHfwq83y6t23746L9ss3Tu4Cldmf+4XedmM6vFLhr9yu1/jSEiHoHaGO2ndXg1EkBOkBuoY6yDhU73G8pdi2XQ5s+5Ww6cc6tnFBUaNxNQmcXxiQ5GShj+ofmTFSrCESkGFpDpw4yokLGs2lwwfSBdjS2y2myMugVT+9iVxogkFx7k98aGGayTyCiS8PuLhK68WFTd/DEeCvlTB1dvEj7KN8DVm4kvIaKPWD33wQRC0Vj0gqT90L tylerfelicidario@TyBook-Pro.attlocal.net"
}
