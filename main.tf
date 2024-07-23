# Define AWS provider
provider "aws" {
  region = "us-west-2"  # Update to your desired region
}

# Define the VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Define subnets in two different Availability Zones
resource "aws_subnet" "example_subnet_az1" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"  # Update to your desired AZ
}

resource "aws_subnet" "example_subnet_az2" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"  # Update to another desired AZ
}

# Define the Internet Gateway
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
}

# Create a custom route table for the subnets
resource "aws_route_table" "example_route_table_az1" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
}

resource "aws_route_table" "example_route_table_az2" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
}

# Associate the subnets with the custom route tables
resource "aws_route_table_association" "example_subnet_association_az1" {
  subnet_id      = aws_subnet.example_subnet_az1.id
  route_table_id = aws_route_table.example_route_table_az1.id
}

resource "aws_route_table_association" "example_subnet_association_az2" {
  subnet_id      = aws_subnet.example_subnet_az2.id
  route_table_id = aws_route_table.example_route_table_az2.id
}

# Define the security group
resource "aws_security_group" "example_security_group" {
  name        = "example-security-group"
  description = "Security group for the Docker host"
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
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

# Define the launch configuration
resource "aws_launch_configuration" "example_launch_config" {
  name_prefix                 = "example-launch-config"
  image_id                    = "ami-0604d81f2fd264c7b"   # Update with your desired AMI
  instance_type               = "t3.medium"                # Update with your desired instance type
  key_name                    = "keypair"                  # Replace with your existing key pair name
  security_groups             = [aws_security_group.example_security_group.id]

  # User data script to initialize Docker and containers
  user_data = file("${path.module}/ec2_instance/init-script.sh")

  associate_public_ip_address = true

  lifecycle {
    create_before_destroy     = true
  }
}

# Define the Auto Scaling group
resource "aws_autoscaling_group" "example_asg" {
  name                        = "example-asg"
  launch_configuration        = aws_launch_configuration.example_launch_config.id
  vpc_zone_identifier         = [
    aws_subnet.example_subnet_az1.id,
    aws_subnet.example_subnet_az2.id,
  ]  # Subnets from different AZs
  max_size                    = 3   # Maximum number of instances
  min_size                    = 1   # Minimum number of instances
  desired_capacity            = 1   # Initial number of instances

  health_check_type           = "EC2"
  health_check_grace_period   = 300  # Adjust as needed
  default_cooldown            = 300  # Cooldown period in seconds

  tag {
    key                       = "Name"
    value                     = "example-asg"
    propagate_at_launch       = true
  }

  target_group_arns           = [aws_lb_target_group.example_target_group.arn]  # Link to ALB target group
  
  lifecycle {
    create_before_destroy = true
  }
}

# Define the Application Load Balancer (ALB)
resource "aws_lb" "example_alb" {
  name               = "example-alb"
  internal           = false  # Set to true if internal ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.example_security_group.id]

  # Replace with your subnet IDs from different Availability Zones
  subnets = [
    aws_subnet.example_subnet_az1.id,
    aws_subnet.example_subnet_az2.id,
  ]

  enable_deletion_protection = false

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "example-alb"
  }
}

# Define the ALB Target Group
resource "aws_lb_target_group" "example_target_group" {
  name        = "example-target-group"
  port        = 8080  # Port your application listens on
  protocol    = "HTTP"
  vpc_id      = aws_vpc.example_vpc.id

  health_check {
    path                = "/"
    port                = 8080
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  stickiness {
    type               = "lb_cookie"
    cookie_name        = "my-alb-cookie"
    cookie_duration    = 3600  # Optional: Cookie duration in seconds
  }
}

# Define the ALB Listeners
resource "aws_lb_listener" "example_listener_80" {
  load_balancer_arn = aws_lb.example_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_target_group.arn
  }
}

resource "aws_lb_listener" "example_listener_8080" {
  load_balancer_arn = aws_lb.example_alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_target_group.arn
  }
}

# Define CloudWatch alarms and Auto Scaling policies
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"

  alarm_description   = "This metric monitors EC2 CPU utilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example_asg.name
  }

  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"

  alarm_description   = "This metric monitors EC2 CPU utilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example_asg.name
  }

  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]
}

# Define scaling policies
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "scale_out_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.example_asg.name
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale_in_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.example_asg.name
}

# Use a data source to get instances in the Auto Scaling Group
data "aws_instances" "example_instances" {
  filter {
    name   = "tag:Name"
    values = ["example-asg"]
  }
}