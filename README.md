# Terraform Modules AWS IAM Identity Center Permission Sets

This module is intended to run in the [delegated identity administrator account]
for [IAM Identity Center]. This module can be used to provision and assign
permission sets to groups and accounts. This allows permissions for an AWS
landing zone to be managed via Terraform CI/CD in the Identity account.

Usage:

``` terraform
module "permission_sets" {
  source = "github.com/thoughtbot/terraform-aws-iam-permission-sets?ref=VERSION"

  # Define your permission sets here. You can include managed policies as well
  # as an inline policy.
  permission_sets = [
    {
      description      = "Describe what your permission set allows"
      managed_policies = ["arn:aws:iam::aws:policy/PowerUserAccess"]
      name             = "Example"
    }
  ]

  # For each group, assign a list of permission sets to each account.
  group_assignments = {
    "aws-admins@example.com.com" = {
      Identity   = ["Example"]
      Production = ["Example"]
      Sandbox    = ["Example"]
    }
  }

  # Because the identity account doesn't have access to list the accounts in the
  # AWS organization, any accounts to which you'd like to assign permission sets
  # must be explicitly listed here.
  account_ids = {
    Identity   = "123456789010"
    Production = "123456789010"
    Sandbox    = "123456789010"
  }

  # How long a user can assume a permission set without logging in again.
  default_session_duration = "PT8H"
}
```

[delegated identity administrator account]: https://docs.aws.amazon.com/singlesignon/latest/userguide/delegated-admin.html
[IAM Identity Center]: https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssoadmin_account_assignment.groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_customer_managed_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_identitystore_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | Account ID for each account name referenced in an assignment | `map(string)` | n/a | yes |
| <a name="input_default_session_duration"></a> [default\_session\_duration](#input\_default\_session\_duration) | Session duration for permission sets without an explicit value | `string` | n/a | yes |
| <a name="input_group_assignments"></a> [group\_assignments](#input\_group\_assignments) | Permission sets to be assigned to each group and account | `map(map(list(string)))` | n/a | yes |
| <a name="input_permission_sets"></a> [permission\_sets](#input\_permission\_sets) | Permission sets which should be defined by this module | <pre>list(object({<br>    description               = string,<br>    inline_policy             = optional(string),<br>    managed_policies          = optional(list(string), []),<br>    customer_managed_policies = optional(list(string), []),<br>    name                      = string,<br>    relay_state               = optional(string),<br>    session_duration          = optional(string),<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
