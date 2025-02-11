provider "aws" {
  region = "ap-southeast-1" # Change this to your desired region
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get first availability zone in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get default subnet in the first AZ
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = data.aws_availability_zones.available.names[0]
  default_for_az    = true
}

module "devbox" {
  source = "./modules/ec2-devbox"

  name_prefix = "devbox"
  vpc_id      = data.aws_vpc.default.id
  subnet_id   = data.aws_subnet.default.id

  instance_type    = "t3.micro"
  root_volume_size = 30

  tags = {
    Environment = "Development"
    Terraform   = "true"
    Name        = "DevBox"
  }
}
