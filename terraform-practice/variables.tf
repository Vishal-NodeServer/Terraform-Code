

variable "ami" {
  type    = string
  default = "ami-0d2614eafc1b0e4d2"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}


variable "volume_size" {
  type    = list(number)
  default = [10, 20, 30] // 3 instances
}

variable "volume_type" {
  type    = string
  default = "gp3"
}

variable "counts" {
  type = list(number)
  default = [1, 2, 3]
}

//hcl - hashicorp configuration language




