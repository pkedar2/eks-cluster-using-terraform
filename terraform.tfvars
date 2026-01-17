region = "us-east-1"

vpc_cidr = "10.0.0.0/16"

public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

azs = [
  "us-east-1a",
  "us-east-1b"
]

cluster_name = "my-eks-cluster"

node_instance_type = "t3.medium"
node_desired        = 2
node_min            = 2
node_max            = 4

ec2_ami = "ami-0c02fb55956c7d316"

