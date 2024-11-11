provider "aws" {
    region = "eu-west-2"
}


/*
We create our variables which we will assign 
at the end
*/

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1"{
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone 
    tags = {
    Name: "${var.env_prefix}-subnet-1"
    }
}

/*
We have the availability zone as a variable also set
and we can decide in which az of the region the subnet will be created 
and the EC2 will be deployed in. And lets also change the name tag 

We change the name tag so for every component that were 
creating lets give it a prefix of the environment 
that its going to be deployed in. So in a development environment
components will have a dev prefix and so on. So we create a variable
called env_prefix {}. So what we do is string interpolation
thats basically having variable value and string glued together
so were going to something like dev-vpc and this dev will be basically
a prefix that is be set as a variable and in order to use this variable
value were going to do ${} so using the variable outside 
not inside the string or inside the quotes is var.variable name
If we want to use a variable inside a string because we want to glue it 
or put it together with another string we are using ${var.env_prefix}-vpc



*/

resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

resource "aws_route_table_association" "a-rtb-subnet" {
   subnet_id = aws_subnet.myapp-subnet-1.id
   route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_default_route_table" "main-rtb"{
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-main-rtb"
    }


}


resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-sg"
    }
    
}

 resource "aws_default_security_group" "myapp-sg" {
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-default-sg"
    }
    
}

 