variable "public_key_path" {
  description = "Path to Public Key"

  #   default     = "~/.ssh/terraform.pub"
}

variable "key_name" {
  description = "Desired name of AWS key pair"

  #   default     = "dr-tf-key"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}
