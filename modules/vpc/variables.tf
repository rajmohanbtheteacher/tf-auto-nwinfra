variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones for subnet deployment"
  type        = list(string)
}

variable "create_internet_gateway" {
  description = "Whether to create Internet Gateway"
  type        = bool
  default     = false
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateway"
  type        = bool
  default     = false
}

variable "create_public_subnet" {
  description = "Whether to create Public Subnet"
  type        = bool
  default     = false
}