variable "instance_type" {
  description = "The instance type for the EC2 instance"
}

variable "ami" {
  description = "The AMI ID for the EC2 instance"
}

variable "tags" {
  description = "Tags for the EC2 instance"

}

variable "volume_size" {
  description = "List of volume sizes for instances"
  type        = number
}

variable "volume_type" {
  description = "Volume type for the block devices"
  type        = string
}



locals {
  name = "example"
}

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = local.name
  }
}
