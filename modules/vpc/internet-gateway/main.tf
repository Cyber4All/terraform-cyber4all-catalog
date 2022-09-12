resource "aws_internet_gateway" "igw" {
    vpc_id = path.root.aws_vpc.vpc.id


    depends_on = [
      aws_vpc.vpc
    ]
}