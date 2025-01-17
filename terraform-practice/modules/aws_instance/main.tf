provider "aws" {
  region = "us-east-1"
}

variable "instance_type" {
  type = string
}

variable "ami" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "counts" {
  type = list(number)
}


variable "volume_size" {
  type = number
}

variable "volume_type" {
  type = string
}

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = length(var.counts)
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = var.volume_size[count.index]
    volume_type = var.volume_type

  }
  tags = {
    Name = "example-${count.index}"
  }
}

output "instance_id" {
  value = aws_instance.example.id
}
