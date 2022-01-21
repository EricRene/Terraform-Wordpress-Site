////////////////////////////////////////////////////
// ------------ Elastic File System ------------ //
//////////////////////////////////////////////////

resource "aws_efs_file_system" "final_demo_efs" {
  creation_token = "efs"

  tags = {
    Name = "Final_demo_efs"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
   count = 2
   file_system_id    = aws_efs_file_system.final_demo_efs.id
   subnet_id         = "${aws_subnet.web_server_subnets.*.id[count.index]}"
   security_groups   = [aws_security_group.efs_sg.id]
 }
