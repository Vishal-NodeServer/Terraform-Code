provider "aws" {
  region = "ap-south-1"
}

locals {
  project = "terraform-practice"
}

module "aws_instance" {
  source        = "./modules/aws_instance"
  count         = 3
  ami           = var.ami
  instance_type = var.instance_type
  volume_size   = var.volume_size[count.index]
  volume_type   = var.volume_type
  tags = {
    Name = "${local.project}-instance-${count.index}"
  }
}
#   Count example with local and index , --> good job vishal

# locals {
#   project = "terraform-practice"
# 
# }
# 
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "vpc-${local.project}"
#   }
# }
# locals {
#   project = "terraform-practice"
# 
# }
# 
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "vpc-${local.project}"
#   }
# }
# 
# 
# 
# resource "aws_subnet" "name" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.${count.index}.0/24" //10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
#   count      = 3
#   tags = {
#     Name = "${local.project}-subnet-${count.index}"
#   }
# }


variable "ec2_map" {
  type = map(object({
    ami           = string
    instance_type = string
  }))
}

locals {
  ec2_map = {
    "ubuntu" = {
      ami           = "ami-0d2614eafc1b0e4d2"
      instance_type = "t2.micro"
    },
    "centos" = {
      ami           = "ami-0d2614eafc1b0e4d2"
      instance_type = "t2.micro"
    }
  }
}

resource "aws_instance" "name" { // its create 2 instance because we have 2 key in local.ec2_map
  for_each      = local.ec2_map
  ami           = each.value.ami
  instance_type = each.value.instance_type

  subnet_id = element(aws_subnet.name.*.id, index(keys(local.ec2_map), each.key)) // its create 2 subnet because we have 2 key in local.ec2_map

  tags = {
    Name = "${local.project}-instance-${each.key}"
  }
}




//database ---> collection ---> document ---> field ---> value

//example : 

