provider "aws " {
 region = "${var.aws_region} "
 profile = "${var.aws_profile} "
}

# IAM
# s3_access_key

# VPC
resource "aws_vpc " "vpc " {
  cidr_block = "10.1.0.0/16 "
}

# Internet gateway
resource "aws_internet_gateway " "internet_gateway " {
  vpc_ic = "${aws_vpc.vpc.id} "
}

# Public route table

resource "aws_route_table " "public " {
  vpc_id = "${aws_vpc.vpc.id} "
  route{
   cidr_block = "0.0.0.0/0 "
   gateway_id = "${aws_internet_gateway.internet_gateway.id} "
 }
  tags{
   Name = "public "
 }
}

# Private route table
resource "aws_route_table " "private " {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id} "
  tags{
   Name = "private "
 }
}

# Subnets - public
resource "aws_subnet " "public " {
  vpc_id = "${aws_vpc.vpc.id} "
  cidr_block = "10.1.1.0/24 "
  map_public_ip_on_launch =true
  availability_zone = "us-east-1d "
  tags{
   Name = "public "
 }
}

# Private Subnet-1
resource "aws_subnet " "private1 " {
  vpc_id = "${asw_vpc.vpc.id} "
  cidr_block = "10.1.2.0/24 "
  map_public_ip_on_launch =false
  availability_zone = "us-east-1a "
  tags{
   Name = "private1 "
 }
}

# Private Subnet-2
resource "aws_subnet " "private2 " {
  vpc_id = "${asw_vpc.vpc.id} "
  cidr_block = "10.1.3.0/24 "
  map_public_ip_on_launch =false
  availability_zone = "us-east-1c "
  tags{
   Name = "private2 "
 }
}

# RDS-1
resource "aws_subnet " "rds1 " {
  vpc_id = "${asw_vpc.vpc.id} "
  cidr_block = "10.1.4.0/24 "
  map_public_ip_on_launch =false
  availability_zone = "us-east-1a "
  tags{
   Name = "rds1 "
 }
}

# RDS-2
resource "aws_subnet " "rds2 " {
  vpc_id = "${asw_vpc.vpc.id} "
  cidr_block = "10.1.5.0/24 "
  map_public_ip_on_launch =false
  availability_zone = "us-east-1b "
  tags{
   Name = "rds2 "
 }
}

# RDS-3
resource "aws_subnet " "rds3 " {
  vpc_id = "${asw_vpc.vpc.id} "
  cidr_block = "10.1.6.0/24 "
  map_public_ip_on_launch =false
  availability_zone = "us-east-1c "
  tags{
   Name = "rds3 "
 }
}

# Subnet associations
resource "aws_route_table_association " "public_association " {
  subnet_id = "${aws_subnet.public.id} "
  route_table_id = "${aws_route_table.public.id} "
}

resource "aws_route_table_association " "private1_association " {
  subnet_id = "${aws_subnet.private1.id} "
  route_table_id = "${aws_route_table.public.id} "
}

resource "aws_route_table_association " "private2_association " {
  subnet_id = "${aws_subnet.private2.id} "
  route_table_id = "${aws_route_table.public.id} "
}

resource "aws_db_subnet_group " "rds_subnetgroup " {
  name = "rds_subnetgroup "
  subnet_ids =[
   "${aws_subnet.rds1.id} ",
   "${aws_subnet.rds2.id} ",
   "${aws_subnet.rds3.id} "
 ]

  tags{
   Name = "rds_sng "
 }
}

# Security Groups
resource "aws_security_group " "public " {
 name = "sg_public "
 description = " "
 vpc_id = "${aws_vpc.vpc.id} "

 ingress{
  from_port =22
  to_port =22
  protocol = "tcp "
  cidr_blocks =[
    "${var.localip} "
  ]
 }

 ingress{
  from_port =80
  to_port =80
  protocol = "http "
  cidr_blocks =[
    "0.0.0.0/0 "
  ]
 }

 egress{
  from_port =0
  to_port =0
  protocol = "-1 "
  cidr_blocks =[
    "0.0.0.0/0 "
  ]
 }
}

resource "aws_security_group " "private " {
 name = "sg_private "
 description = " "
 vpc_id = "${aws_vpc.vpc.id} "

 ingress{
  from_port =0
  to_port =0
  protocol = "-1 "
  cidr_blocks =[
    "10.1.0.0/16 "
  ]
 }

 egress{
  from_port =0
  to_port =0
  protocol = "-1 "
  cidr_blocks =[
    "0.0.0.0/0 "
  ]
 }
}

resource "aws_security_group " "RDS " {
 name = "sg_rds "
 description = " "
 vpc_id = "${aws_vpc.vpc.id} "

 ingress{
  from_port =3306
  to_port =3306
  protocol = "tcp "
  security_groups =[
    "${aws_security_group.public.id} ",
    "${aws_security_group.private.id} "
  ]
 }

 egress{
  from_port =0
  to_port =0
  protocol = "-1 "
  cidr_blocks =[
    "0.0.0.0/0 "
  ]
 }
}

# Database
resource "aws_db_instance " "db " {
  allocated_storage = 10
  engine = "mysql"
  engine_version = "5.6.27"
  instance_class = "${var.db_instance_class}"
  name = "${var.dbname}"
  username = "${var.dbuser}"
  password = "${var.dbpassword}"
  db_subnet_group_name = "${aws_db_subnet_group.rds_subnetgroup.name}"
  vpc_security_group_ids = ["${aws_security_group.RDS.id}"]
}
# S3 code bucket

# Compute
# Key Pair
# Dev Server
# - ansible playbook
# Load balancer
# AMI from dev instance
# Launch configuration
# aws_region

# Route53
# Primary Zone
# www record
# dev record
# db record
