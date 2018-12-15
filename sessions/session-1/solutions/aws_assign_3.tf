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






