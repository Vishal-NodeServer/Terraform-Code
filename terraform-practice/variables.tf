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
  default = [10, 20, 30]
}

variable "volume_type" {
  type    = string
  default = "gp3"
}

variable "tags" {
  description = "Additional tags for EC2 instances"
  type        = map(string)
  default     = {}
}

