////////////////////////////////////////////////
// ------------ Security Groups ------------ //
//////////////////////////////////////////////

resource "aws_security_group" "alb_sg" {
  name        = "ALB-SG"
  description = "Application load balancer security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "Allows https requests"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "web_server_sg" {
  name        = "Web-Server-SG"
  description = "Web Server security group"
  vpc_id      = aws_vpc.my_vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_security_group_rule" "web_server_sg_rule" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web_server_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group" "database_sg" {
  name        = "Database-SG"
  description = "Database security group"
  vpc_id      = aws_vpc.my_vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "Database_sg_rule" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.database_sg.id
  source_security_group_id = aws_security_group.web_server_sg.id
}

resource "aws_security_group" "efs_sg" {
   name = "efs_security_group"
   description= "Allows inbound efs traffic from ec2"
   vpc_id = aws_vpc.my_vpc.id

   ingress {
     security_groups = [aws_security_group.web_server_sg.id]
     from_port = 2049
     to_port = 2049
     protocol = "tcp"
   }

   egress {
     security_groups = [aws_security_group.web_server_sg.id]
     from_port = 0
     to_port = 0
     protocol = "-1"
   }
 }






 # resource "aws_security_group" "endpoint_sg" {
 #   name        = "Endpoint-SG"
 #   description = "Endpoint security group"
 #   vpc_id      = aws_vpc.my_vpc.id
 #
 #   egress {
 #     from_port        = 0
 #     to_port          = 0
 #     protocol         = "-1"
 #     cidr_blocks      = ["0.0.0.0/0"]
 #     ipv6_cidr_blocks = ["::/0"]
 #   }
 # }
 # 
 # resource "aws_security_group_rule" "Endpoint_sg_rule" {
 #   type                     = "ingress"
 #   from_port                = 443
 #   to_port                  = 443
 #   protocol                 = "tcp"
 #   security_group_id        = aws_security_group.endpoint_sg.id
 #   source_security_group_id = aws_security_group.web_server_sg.id
 # }
