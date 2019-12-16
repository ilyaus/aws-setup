provider "aws " {
 region = "${var.aws_region} "
 profile = "${var.aws_profile} "
}

# IAM
# s3_access_key
resource "aws_iam_instance_profile" "s3_access" {
  name = "s3_access"
  role = ["${aws_iam_role.s3_access_name}"]
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "s3_access" {
  name = "s3_access"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    "Action": "sts:AssumeRole",
    "Principle": {
      "Service": "ec2.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
  ]
}
EOF
}
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

# Create S3 VPC endpoint
resource "aws_vpc_endpoint" "private-s3" {
  vpc_id = "${aws_vpc.vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [
    "${aws_vpc.vpc.main_route_table_id}",
    "${aws_route_table.public.id}"
  ]
  policy = <<POLICY
{
  "Statement": [
    "Action": "*",
    "Effect": "Allow",
    "Resource": "*",
    "Principle": "*"
  ]
}
POLICY
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
resource "aws_s3_bucket" "code" {
  bucket = "${var.domain_name}_code3214"
  acl = "private"
  force_destroy = true
  tags {
    Name = "CodeBucket"
  }
}

# Compute

# Key Pair
resource "aws_key_pair" "auth" {
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# Dev Server
resource "aws_instance" "dev" {
  instance_type = "${var.dev_instance_type}"
  ami = "${var.dev_ami}"
  tags {
    Name = "dev"
  }

  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  iam_instance_profile "${aws_iam_instance_profile.s3_access.id}"
  subnet_id = "${aws_subnet.public.id}"


  provisioner "local-exec" {
    command = "cat <<EOF > aws_hosts
[dev]
${aws_instance.dev.public_ip}
[dev:vars]
s3code=${aws_s3_bucket.code.bucket}
EOF"
  }

  provisioner "local-exec" {
    command = "sleep 6m && ansible-playbook -i aws_hosts wordpress.yml"
  }

# - ansible playbook
# Load balancer
resource "aws_elb" "prod" {
  name = "${var.domain_name}-prod-elb"
  subnets = ["${aws_subnet.private1.id}", "${aws_subnet.private2.id}"]
  security_groups = ["${aws_security_group.public.id}"]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = "${var.elb_healthy_threshold}"
    unhealthy_threshold = "${var.elb_unhealthy_threshold}"
    timeout = "${var.elb_timeout}"
    target = "HTTP:80/"
    interval = "${var.elb_interval}"
  }
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  tags {
    Name = "${var.domain_name}-prod-elb"
  }
}

# AMI from dev instance
# Launch configuration
# aws_region

# Route53
# Primary Zone
# www record
# dev record
# db record
