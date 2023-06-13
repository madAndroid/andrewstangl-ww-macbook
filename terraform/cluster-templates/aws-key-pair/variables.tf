variable "region" {
  type        = string
  description = "AWS region for cluster"
  default     = "us-east-1"
}

variable "key_pair_name" {
  type        = string
  description = "EC2 key pair name"
}

variable "public_key" {
  type        = string
  description = "ssh public key"
}

variable "tags" {
  type        = map(string)
  description = "resource specific tags"
  default     = {}
}
