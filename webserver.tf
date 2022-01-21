////////////////////////////////////////////////
// ------------ Launch Template ------------ //
//////////////////////////////////////////////

resource "aws_launch_template" "final-demo-launch-template" {
    name_prefix            = "final-demo-launch-template"
    image_id               = "ami-04505e74c0741db8d"
    instance_type          = "t2.micro"
    key_name               = "final-demo-asg-kp"
    vpc_security_group_ids = [aws_security_group.web_server_sg.id]
    user_data              = base64encode("${data.template_file.template_file.rendered}")

    iam_instance_profile {
      name = "secrets_manager_profile"
    }
}

///////////////////////////////////////////////////
// ------------ Auto-Scaling Group ------------ //
/////////////////////////////////////////////////

resource "aws_autoscaling_group" "final-demo-autoscaling-group" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.web_server_subnets[0].id, aws_subnet.web_server_subnets[1].id]


  launch_template {
    id      = aws_launch_template.final-demo-launch-template.id
    version = "$Latest"
  }
}



resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.final-demo-autoscaling-group.id
  alb_target_group_arn   = aws_lb_target_group.my_target_group.arn
}

/////////////////////////////////////////////////
// ------------ Instance Profile ------------ //
///////////////////////////////////////////////

resource "aws_iam_instance_profile" "secrets_manager_profile" {
  name = "secrets_manager_profile"
  role = aws_iam_role.secrets_manager_role.name
}

resource "aws_iam_role" "secrets_manager_role" {
  name = "secrets_manager_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "secrets_manager_policy" {
  name = "secrets_manager_policy"
  role = aws_iam_role.secrets_manager_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds",
                "secretsmanager:ListSecrets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
})
}
