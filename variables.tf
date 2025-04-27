variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI Profile to use"
  type        = string
}

variable "vpcs" {
  description = "VPC details for multiple VPCs"
  type = map(object({
    cidr_block = string
  }))
}

variable "azs" {
  description = "Availability zones to deploy subnets"
  type        = list(string)
}