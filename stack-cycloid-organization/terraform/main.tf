module "tf-backend" {
  #####################################
  # Do not modify the following lines #
  source       = "./module-tf-backend"
  cy_project   = var.cy_project
  cy_env       = var.cy_env
  cy_org       = var.cy_org
  cy_component = var.cy_component
  #####################################

  #. dg_name: ""
  #+ The name of the DG
  dg_name = var.dg_name
}

module "cycloid-org" {
  #####################################
  # Do not modify the following lines #
  source       = "./module-cycloid-org"
  cy_project   = var.cy_project
  cy_env       = var.cy_env
  cy_org       = var.cy_org
  cy_component = var.cy_component
  #####################################

  #. dg_name: ""
  #+ The name of the DG
  dg_name = var.dg_name

  #. cycloid_git_url: ''
  #+ Git repository URL for stacks and config
  cycloid_git_url = "git@github.com:cycloid-demo/${github_repository.cycloid-demo.name}.git"

  #. cycloid_git_ssh_key: ''
  #+ Git repository SSH private key for stacks and config
  cycloid_git_ssh_key = tls_private_key.github_generated_key.private_key_openssh

  #. cycloid_s3_access_key: ''
  #+ S3 bucket access_key for Terraform state files
  cycloid_s3_access_key = module.tf-backend.iam_user_access_key

  #. cycloid_s3_secret_key: ''
  #+ S3 bucket secret_key for Terraform state files
  cycloid_s3_secret_key = module.tf-backend.iam_user_secret_key

  #. cycloid_s3_region: 'us-east-1'
  #+ S3 bucket region for Terraform state files
  cycloid_s3_region = var.aws_region

  #. private_key_openssh: ''
  #+ SSH Key Pair used in newly provisionned workloads
  private_key_openssh = module.tf-backend.aws_private_key_openssh

  #. aws_sel: ''
  #+ Shall we provision an AWS account in the new DG."
  aws_sel = var.aws_sel

  #. aws_cred_child: ''
  #+ Shall we provision an AWS account in the new DG."
  aws_cred_child = var.aws_cred_child

  #. azure_sel: ''
  #+ Shall we provision an AWS account in the new DG."
  azure_sel = var.azure_sel

  #. azure_cred_child: ''
  #+ Shall we provision an Azure account in the new DG."
  azure_cred_child = var.azure_cred_child
}