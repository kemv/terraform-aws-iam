provider "aws" {
  region = local.region
}

locals {
  name   = "ex-irsa"
  region = "eu-west-1"

  trust_anchor_arn = "arn:aws:rolesanywhere:eu-central-1:123456789012:trust-anchor/00000000-0000-0000-0000-000000000000"
}

module "spiffe_role" {
  source = "../../modules/iam-role-for-service-accounts-eks-with-spiffe"
  role_name        = local.name
  role_description = "Some IAM role supporting both SPIFFE and OIDC"

  oidc_providers = {
    my-oidc = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:my-app", "canary:my-app"]
    }
  }

  trust_domains = {
    "spiffe.somecompany.org" = {
      trust_anchor_arn           = local.trust_anchor_arn
      namespace_service_accounts = [
        {
          namespace = "default",
          service_account = "my-app"
        }
      ]
    },
    "canary.spiffe.somecompany.org" = {
      trust_anchor_arn           = local.trust_anchor_arn
      namespace_service_accounts = [
        {
          namespace = "canary",
          service_account = "my-app"
        }
      ]
    }
  }
}
