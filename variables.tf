variable "instance_type" {
  description = "The EC2 instance type"
  default     = "t2.medium"
}

variable "git_repo_url" {
  description = "The URL of the Git repository containing the project code"
  default     = "https://github.com/oblivion3107/docker_tf.git" # Update with your repository URL
}
