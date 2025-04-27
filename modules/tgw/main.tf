resource "aws_ec2_transit_gateway" "this" {
  description = "Project Transit Gateway"
  tags = {
    Name = "project-transit-gateway"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "attachment" {
  for_each = var.vpcs

  subnet_ids         = each.value.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id

  tags = {
    Name = "${each.key}-tgw-attachment"
  }
}