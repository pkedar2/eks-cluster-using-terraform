
**What this builds** 

Everything is set up for the us-east-1 region. Here is the high-level infrastructure:

**Networking**: A clean VPC (10.0.0.0/16) with an Internet Gateway and Route Tables. It creates two public subnets to ensure the cluster is accessible and highly available.

**EKS Cluster**: A cluster named my-eks-cluster.

**Worker Nodes**: A managed node group running t3.medium instances. It starts with 2 nodes and can scale up to 4 if the load gets high.

**IAM Roles**: All the necessary permissions and roles for the cluster and nodes are handled automatically.

**Jump Box**: A small t2.micro EC2 instance. You can use this as a bastion host or for debugging.

**Security**: A security group that opens port 22 (SSH) so you can access the EC2 instance.

Before you start

Make sure you have these tools installed locally:

**Terraform**

AWS CLI (configured with your credentials)

How to run it :

**Init**: Open your terminal in this folder and run:

$terraform init

**Plan**: check what services terraform is going to create:

$$terraform plan

**Deploy**: Apply the code to build the infrastructure:

$terraform apply

(Type yes when it asks for confirmation).




<img width="3456" height="1024" alt="image" src="https://github.com/user-attachments/assets/3f4e6b2f-9b48-4739-a0d7-70d066ddc842" />
<img width="2866" height="608" alt="image" src="https://github.com/user-attachments/assets/fc88c552-3bc4-4093-80ad-1fd87e8e6942" />
<img width="2974" height="836" alt="image" src="https://github.com/user-attachments/assets/d0d38a15-dfe2-4793-832a-34a69340e766" />

**Remote State & Locking Setup**

S3 for remote state storage and DynamoDB for state locking. This ensures that the state file is stored securely in the cloud and prevents multiple people from running commands at the same time.

**How to Initialize **

Since this project is not modulerized so S3 bucket and DynamoDB table are managed within the same code, follow these steps to avoid "Bucket Not Found" errors during the first run:

**Local Init**: Comment out the backend "s3" block in main.tf.

**Provision Storage**: Run the following command to build the storage first:

$terraform init

$terraform apply -target=aws_s3_bucket.state_bucket -target=aws_dynamodb_table.state_lock

**Enable Remote State**: Uncomment the backend "s3" block in main.tf.

Migrate State: Run the final initialization to move your local state to the cloud:

$terraform init

(Type yes when prompted to migrate the state).

Why this is important?

**State Locking**: The DynamoDB table creates a lock during operations. If you try to run apply while another process is running, Terraform will block the action to prevent state corruption.

Durability: S3 versioning is enabled on the bucket, allowing you to recover older versions of your infrastructure state if something goes wrong.

**Troubleshooting Locks**

If your process crashes and the state remains locked, you might see an error. You can manually release the lock using the ID provided in the error message:

terraform force-unlock <LOCK_ID>

<img width="3456" height="524" alt="image" src="https://github.com/user-attachments/assets/8aa76bfd-52e3-4763-a60d-a1b444608b0c" />
<img width="3456" height="870" alt="image" src="https://github.com/user-attachments/assets/c14f6e47-7c4f-4c2b-8e63-29678bd3fed6" />



