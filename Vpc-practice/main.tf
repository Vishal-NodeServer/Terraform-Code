# Create VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Subnets
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

# Route Table and Associations
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

# Security Group
resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# IAM Role and S3 Bucket
resource "aws_iam_role" "s3_access_role" { //this is the role that will be attached to the ec2 instance
  name = "s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" //this is the service that will be used to assume the role
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" { //this is the policy that will be attached to the role
  name        = "s3_access_policy"
  description = "Policy to allow S3 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = ["arn:aws:s3:::vishalsuthar-terraform-practice-bucket-2004/*", "arn:aws:s3:::vishalsuthar-terraform-practice-bucket-2004"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "vishalsuthar-terraform-practice-bucket-2004"

  tags = {
    Name = "vishalsuthar-terraform-practice-bucket-2004"
  }
}

resource "aws_s3_object" "myfile" {
  bucket = aws_s3_bucket.mybucket.bucket
  key    = "data.txt"   # The name of the file in S3
  source = "./data.txt" # Local file path to upload
  acl    = "private"    # Access control (can be modified as needed)
}


resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3-access-profile"
  role = aws_iam_role.s3_access_role.name
}




# EC2 Instances
resource "aws_instance" "webserver1" {
  ami                    = "ami-0d2614eafc1b0e4d2"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.s3_access_profile.name
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata.sh"))
}

resource "aws_instance" "webserver2" {
  ami                    = "ami-0d2614eafc1b0e4d2"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.s3_access_profile.name
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata1.sh"))
}

# Load Balancer
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.webSg.id]
  subnets         = [aws_subnet.sub1.id, aws_subnet.sub2.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}

output "webserver1ip" {
  value = aws_instance.webserver1.public_ip
}

output "webserver2ip" {
  value = aws_instance.webserver2.public_ip
}

output "s3_access_profile_arn" {
  value = aws_iam_instance_profile.s3_access_profile.arn
}
