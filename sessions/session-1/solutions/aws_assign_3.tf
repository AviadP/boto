##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_name" {}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

##################################################################################
# RESOURCES
##################################################################################

### Network Elements ###
resource "aws_vpc" "ops_assign_3" {
    cidr_block           = "10.10.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
        "Name" = "vpc_ops_assign_3"
        "Project" = "Opsschool_terraform_assingment"
    }
}
resource "aws_subnet" "public_c" {
    vpc_id                  = "${aws_vpc.ops_assign_3.id}"
    cidr_block              = "10.10.3.0/24"
    availability_zone       = "us-east-1c"
    map_public_ip_on_launch = false

    tags {
        "Name" = "public_c"
        "Project" = "Opsschool_terraform_assingment"
    }
}
resource "aws_subnet" "private_c" {
    vpc_id                  = "${aws_vpc.ops_assign_3.id}"
    cidr_block              = "10.10.30.0/24"
    availability_zone       = "us-east-1c"
    map_public_ip_on_launch = false

    tags {
        "Name" = "private_c"
        "Project" = "Opsschool_terraform_assingment"
    }
}
resource "aws_subnet" "public_d" {
    vpc_id                  = "${aws_vpc.ops_assign_3.id}"
    cidr_block              = "10.10.4.0/24"
    availability_zone       = "us-east-1d"
    map_public_ip_on_launch = false

    tags {
        "Name" = "public_d"
        "Project" = "Opsschool_terraform_assingment"
    }
}
resource "aws_subnet" "private_d" {
    vpc_id                  = "${aws_vpc.ops_assign_3.id}"
    cidr_block              = "10.10.40.0/24"
    availability_zone       = "us-east-1d"
    map_public_ip_on_launch = false

    tags {
        "Name" = "private_d"
        "Project" = "Opsschool_terraform_assingment"
    }
}
resource "aws_internet_gateway" "igw" {
   vpc_id = "${aws_vpc.ops_assign_3.id}"
}
resource "aws_eip" "nat_eip" {
}
resource "aws_nat_gateway" "ngw" {
   allocation_id = "${aws_eip.nat_eip.id}"
   subnet_id     = "${aws_subnet.public_c.id}"

   tags {
       "Name" = "gw NAT"
       "Project" = "Opsschool_terraform_assingment"
   }
}
resource "aws_route_table" "local" {
    vpc_id     = "${aws_vpc.ops_assign_3.id}"

    tags {
        "Name" = "localRouting"
        "Project" = "Opsschool_terraform_assingment"
    }
}

resource "aws_route_table" "toNATGW" {
    vpc_id     = "${aws_vpc.ops_assign_3.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.ngw.id}"
    }

    tags {
        "Name" = "toNATGW"
        "Project" = "Opsschool_terraform_assingment"
    }
}

resource "aws_route_table" "toIGW" {
    vpc_id     = "${aws_vpc.ops_assign_3.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags {
        "Name" = "routeToIGW"
        "Project" = "Opsschool_terraform_assingment"
    }
}
resource "aws_route_table_association" "privateCtoNAT" {
    route_table_id = "${aws_route_table.toNATGW.id}"
    subnet_id = "${aws_subnet.private_c.id}"
}
resource "aws_route_table_association" "privateDtoNAT" {
    route_table_id = "${aws_route_table.toNATGW.id}"
    subnet_id = "${aws_subnet.private_d.id}"
}
resource "aws_route_table_association" "publicCtoIGW" {
    route_table_id = "${aws_route_table.toIGW.id}"
    subnet_id = "${aws_subnet.public_c.id}"
}
resource "aws_route_table_association" "publicDtoIGW" {
    route_table_id = "${aws_route_table.toIGW.id}"
    subnet_id = "${aws_subnet.public_d.id}"
}
########### Security Group ##################
resource "aws_security_group" "general_sg" {
    name        = "GeneralSG"
    description = "default VPC security group"
    vpc_id      = "${aws_vpc.ops_assign_3.id}"

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        security_groups = []
        self            = true
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}
########### EC2 instances ###################
resource "aws_instance" "nginx_c" {
    ami                         = "ami-0ac019f4fcb7cb7e6"
    availability_zone           = "us-east-1c"
    instance_type               = "t2.micro"
    key_name                    = "virginia_default"
    subnet_id                   = "${aws_subnet.private_c.id}"
    vpc_security_group_ids      = ["${aws_security_group.general_sg.id}"]
    associate_public_ip_address = false

    root_block_device {
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }

    provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo service nginx start"
    ]
  }

    tags {
        "Name" = "nginx_c"
        "Project" = "Opsschool_terraform_assingment"
    }
}
resource "aws_instance" "nginx_d" {
    ami                         = "ami-0ac019f4fcb7cb7e6"
    availability_zone           = "us-east-1d"
    instance_type               = "t2.micro"
    key_name                    = "virginia_default"
    subnet_id                   = "${aws_subnet.private_d.id}"
    vpc_security_group_ids      = ["${aws_security_group.general_sg.id}"]
    associate_public_ip_address = false

    root_block_device {
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }

    provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo service nginx start"
    ]
  }

    tags {
        "Name" = "nginx_d"
        "Project" = "Opsschool_terraform_assingment"
    }
}







