provider "aws" {
  region = "us-east-1"
}

module "aws_instance" {
  source = "./modules/aws_instance"

  for_each      = tomap({ 0 = "0", 1 = "1", 2 = "2" }) // Convert indices to string keys and and its run the three times means 3 (instance) itration
  ami           = var.ami
  instance_type = var.instance_type
  counts        = 1                           #per itration create 1 instance and after 2 itration it create 1 more instance  and ....               # Single instance per iteration
  volume_size   = var.volume_size[each.value] # Pass size based on index // 0, 1, 2
  volume_type   = var.volume_type

  tags = {
    Environment = "dev"
    Owner       = "Vishal"
  }
}
