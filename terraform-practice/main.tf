provider "aws" {
  region = "us-east-1"
}

module "aws_instance" {
  source        = "./modules/aws_instance"
  ami           = var.ami
  instance_type = var.instance_type
  counts        = var.counts
  volume_size   = var.volume_size[count.index]
  volume_type   = var.volume_type

  tags = {
    Name = "example-${count.index}"
  }

}


