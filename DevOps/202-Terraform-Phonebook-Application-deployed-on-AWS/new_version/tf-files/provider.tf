terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region     = "us-east-1" // Thanks to the aws configure process, there is no need to write our access and secret key information here.
  access_key = "AKIAQA4ST5VLRVYAYELH"
  secret_key = "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"
}

provider "github" {
  token = var.git-token
}
#  In infrastructure-as-code tools like Terraform, a provider is responsible for interacting with a specific API or service to manage and provision resources.
# In this case, the "github" provider is used to interact with the GitHub platform. By specifying the GitHub provider and providing a token, you can authenticate and authorize Terraform to perform operations on your GitHub repositories, organizations, and other related resources.
# The purpose of the GitHub provider is to enable you to manage your GitHub infrastructure and configurations programmatically using Terraform. This includes creating and managing repositories, managing repository settings, configuring webhooks, managing teams and collaborators, and more. By leveraging the GitHub provider, you can automate the provisioning and configuration of your GitHub resources alongside other infrastructure resources you manage with Terraform.