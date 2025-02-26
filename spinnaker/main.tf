# Complete example

terraform {
  required_version = "~> 0.14.2"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}

provider "aws" {
  alias               = "prod"
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}


module "opencloudcx" {
  source  = "OpenCloudCX/opencloudcx/aws"
  version = ">= 0.3.6"

  name               = "example"
  stack              = "dev"
  detail             = "module-test"
  tags               = { "env" = "dev" }
  region             = "us-east-1"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cidr               = "10.0.0.0/16"
  dns_zone           = "your.private"
  kubernetes_version = "1.18"
  kubernetes_node_groups = {
    default = {
      instance_type = "m5.large"
      min_size      = "1"
      max_size      = "3"
      desired_size  = "2"
    }
  }
  aurora_cluster = {
    node_size = "1"
    node_type = "db.t3.medium"
    version   = "5.7.12"
  }
  helm_chart_version = "2.2.3"
  helm_chart_values  = [file("values.yaml")]
  assume_role_arn    = [module.spinnaker-managed-role.role_arn]
}

# spinnaker managed role
module "spinnaker-managed-role" {
  source  = "OpenCloudCX/opencloudcx/aws//modules/spinnaker-managed-aws"
  version = "~> 0.3.6"

  providers        = { aws = aws.prod }
  name             = "example"
  stack            = "dev"
  trusted_role_arn = [module.opencloudcx.role_arn]
}
