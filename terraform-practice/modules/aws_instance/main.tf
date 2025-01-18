# Remove provider block as it should be in root module
variable "instance_type" {
  description = "value"
}

variable "ami" {
  description = "value"
}

variable "tags" {
  description = "value"
}

variable "counts" {
  description = "value"
}

variable "volume_size" {
  description = "value"

}

variable "volume_type" {
  description = "value"
}

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = var.counts

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = merge(
    var.tags,
    {
      Name = "example-${count.index}"
    }
  )
}

