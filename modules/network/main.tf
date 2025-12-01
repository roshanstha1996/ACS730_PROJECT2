resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    Project     = "ACS730-FinalProject"
    ManagedBy   = "Terraform"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
    Project     = "ACS730-FinalProject"
    ManagedBy   = "Terraform"
  }
}
data "aws_availability_zones" "available" {}

resource "aws_subnet" "private" {
  count                   = 3
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 10) # separate range
  vpc_id                  = aws_vpc.this.id
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-private-${count.index}"
    Environment = var.environment
    Project     = "ACS730-FinalProject"
    ManagedBy   = "Terraform"
    Tier        = "Private"
  }
}

resource "aws_subnet" "public" {
  count                   = 3
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  vpc_id                  = aws_vpc.this.id
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-public-${count.index}"
    Environment = var.environment
    Project     = "ACS730-FinalProject"
    ManagedBy   = "Terraform"
    Tier        = "Public"
  }
}

# NAT Gateway + EIP
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

