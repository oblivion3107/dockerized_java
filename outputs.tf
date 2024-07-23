output "subnet_id_az1" {
  value = aws_subnet.example_subnet_az1.id
}

output "subnet_id_az2" {
  value = aws_subnet.example_subnet_az2.id
}

output "security_group_id" {
  value = aws_security_group.example_security_group.id
}

output "load_balancer_dns" {
  value = aws_lb.example_alb.dns_name
}

output "load_balancer_arn" {
  value = aws_lb.example_alb.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.example_target_group.arn
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.example_asg.name
}

output "launch_configuration_id" { 
  value = aws_launch_configuration.example_launch_config.id 
}
