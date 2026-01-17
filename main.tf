provider "aws" {
  region = var.region
}


# VPC & Networking


resource "aws_vpc" "terraform" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "terraform_subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.terraform.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform.id
  tags = {
    Name = "eks-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.terraform.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }
  tags = {
    Name = "eks-rt"
  }
}

resource "aws_route_table_association" "rta" {
  count          = length(aws_subnet.terraform_subnet)
  subnet_id      = aws_subnet.terraform_subnet[count.index].id
  route_table_id = aws_route_table.rt.id
}


# IAM Roles


resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])

  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}


# EKS Cluster & Nodes


resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.terraform_subnet[*].id
  }
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name   = aws_eks_cluster.eks_cluster.name
  node_role_arn  = aws_iam_role.eks_node_role.arn
  subnet_ids     = aws_subnet.terraform_subnet[*].id
  instance_types = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired
    min_size     = var.node_min
    max_size     = var.node_max
  }
}


# EC2 + Security Group


resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.terraform.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "eks-sg"
  }
}

# Outputs


output "ec2_public_ip" {
  value = aws_instance.eks.public_ip
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}
