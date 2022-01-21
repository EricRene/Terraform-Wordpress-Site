//////////////////////////////////////////
// ------------ Variables ------------ //
////////////////////////////////////////

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "region" {}

variable "vpc_cidr" {}

variable "key_name" {}

# variable "db_name" {}

variable "db_username" {}

variable "db_password" {}

variable "public_subnet_names" {
  type = list(string)
  default = [
    "Public Subnet 1",
    "Public Subnet 2"
  ]
}

variable "web_server_subnet_names" {
  type = list(string)
  default = [
    "Web Server Subnet 1",
    "Web Server Subnet 2"
  ]
}

variable "database_subnet_names" {
  type = list(string)
  default = [
    "Database Subnet 1",
    "Database Subnet 2"
  ]
}

/////////////////////////////////////
// ------------ Data ------------ //
//////////////////////////////////

data "aws_availability_zones" "available" {
  state = "available"
}

data "template_file" "template_file" {
  template = "${file("userdata.tftpl")}"
  vars = {
    efs_dns     = "${aws_efs_mount_target.efs_mount_target.0.dns_name}",
    db_endpoint = "${module.db.db_instance_endpoint}",
    lb_dns      = "${aws_lb.my_alb.dns_name}"
  }
}

////////////////////////////////////////
// ------------ Outputs ------------ //
//////////////////////////////////////

output "alb_sg_id" {
    value = aws_security_group.alb_sg.id
}

output "web_server_sg_id" {
    value = aws_security_group.web_server_sg.id
}

output "alb_arn" {
    value = aws_lb.my_alb.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.my_target_group.arn
}

output "database_name" {
  value = module.db.db_instance_name
}

output "database_endpoint" {
  value = module.db.db_instance_endpoint
}

output "database_username" {
  value     = module.db.db_instance_username
  sensitive = true
}

output "database_master_password" {
  value     = module.db.db_master_password
  sensitive = true
}

output "load_balancer_dns" {
  value = aws_lb.my_alb.dns_name
}

output "efs_file_system_id" {
  value = aws_efs_file_system.final_demo_efs.id
}
