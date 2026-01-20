environment                  = "dev"
aws_region                  = "ap-south-1"
instance_type               = "t3.micro"



/*


terraform apply -var-file="env/dev.tfvars" -auto-approve 
terraform plan -var-file="env/dev.tfvars"
terraform apply -var-file="env/dev.tfvars"
terraform destroy -var-file="env/dev.tfvars" -auto-approve
terraform force-unlock <LOCK_ID> 


*/

# topics
/*


Network policies vs Pod security policies (deprecated),
RBAC,
root-container vs non root container,




*/