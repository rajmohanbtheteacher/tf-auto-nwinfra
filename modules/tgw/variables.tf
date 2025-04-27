variable "vpcs" {
  description = "VPC IDs and Subnets to attach to Transit Gateway"
  type = map(object({
    vpc_id     = string
    subnet_ids = list(string)
  }))
}