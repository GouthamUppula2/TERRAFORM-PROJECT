#CREATING A VPC
resource "aws_vpc" "project" {
    cidr_block = var.cidr
}

#CREATING A SUBNET-1
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.project.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

#CREATING A SUBNET-2  
resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.project.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

#CREATING A IGW
resource "aws_internet_gateway" "project-igw" {
    vpc_id = aws_vpc.project.id
}

#CREATING A ROUTE TABLE & ATTACHING TO IGW
resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.project.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id =aws_internet_gateway.project-igw.id
    } 
}

#ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.RT.id
}
resource "aws_route_table_association" "rta2" {
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.RT.id
}

#CREATING SECURITY GROUP & RULES
resource "aws_security_group" "mysg" {
  name="web"
  vpc_id = aws_vpc.project.id

  ingress{
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#S3 BUCKET
resource "aws_s3_bucket" "s3project" {
  bucket = "s3terraformproject20045"
}

#INSTANCE-1 USING SUBNET-1
resource "aws_instance" "web-1" {
  ami="ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id = aws_subnet.subnet1.id
  user_data= base64encode(file("userdata.sh"))
}

#INSTANCE-2 USING SUBNET-2
resource "aws_instance" "web-2" {
  ami="ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id = aws_subnet.subnet2.id
  user_data= base64encode(file("userdata-2.sh"))
}

#LOAD BALANCER
resource "aws_lb" "myalb1" {
    name="myalb1" 
    internal = false
    load_balancer_type = "application"

    security_groups = [ aws_security_group.mysg.id ]
    subnets = [ aws_subnet.subnet1.id,aws_subnet.subnet2.id ]
}

#CREATING TARGET GROUP FOR LOAD BALANCER
resource "aws_lb_target_group" "lb-tg" {
    name = "LBTG"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.project.id

    health_check {
      path = "/"
      port = "traffic-port"
    }
}

#ATTACHING WITH INSTANCE-1
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.lb-tg.arn
  target_id = aws_instance.web-1.id
  port = 80
}

#ATTACHING WITH INSTANCE-2
resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.lb-tg.arn
  target_id = aws_instance.web-2.id
  port = 80
}

#CREATING A LISTENER
resource "aws_lb_listener" "lb-listener" {
    load_balancer_arn = aws_lb.myalb1.arn
    port = 80
    protocol = "HTTP"

    default_action {
      target_group_arn = aws_lb_target_group.lb-tg.arn
      type = "forward"
    }
}

