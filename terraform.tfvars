aws_region  = "us-east-1"
aws_profile = "default"

vpcs = {
  "Gateway-VPC" = { cidr_block = "177.1.0.0/20" }
  "UAT-VPC"     = { cidr_block = "44.1.0.0/16" }
  "DEV-VPC"     = { cidr_block = "22.2.0.0/16" }
  "PROD-VPC"    = { cidr_block = "190.1.0.0/16" }
}

azs = ["us-east-1a", "us-east-1b"]