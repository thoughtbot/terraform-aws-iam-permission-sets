locals {
  identity_store  = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  permission_sets = zipmap(var.permission_sets[*].name, var.permission_sets)
  sso_instance    = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  group_assignment_list = flatten([
    for group_name, accounts in var.group_assignments :
    [
      for account_name, assignments in accounts :
      [
        for assignment in assignments :
        {
          id                  = join("/", [group_name, account_name, assignment])
          account_name        = account_name
          group_name          = group_name
          permission_set_name = assignment
        }
      ]
    ]
  ])

  group_assignment_map = zipmap(
    local.group_assignment_list[*].id,
    local.group_assignment_list
  )

  inline_policies = [
    for permission_set in var.permission_sets :
    {
      permission_set = permission_set.name,
      policy         = permission_set.inline_policy
    } if permission_set.inline_policy != null
  ]

  inline_policy_map = zipmap(
    local.inline_policies[*].permission_set,
    local.inline_policies[*].policy
  )

  managed_policies = flatten([
    for permission_set in var.permission_sets :
    [
      for policy in permission_set.managed_policies :
      {
        id                  = join("/", [permission_set.name, policy])
        permission_set_name = permission_set.name
        policy_arn          = policy
      }
    ]
  ])

  managed_policy_map = zipmap(
    local.managed_policies[*].id,
    local.managed_policies
  )
}

resource "aws_ssoadmin_permission_set" "this" {
  for_each = local.permission_sets

  name             = each.value.name
  description      = each.value.description
  instance_arn     = local.sso_instance
  relay_state      = each.value.relay_state
  session_duration = coalesce(each.value.relay_state, var.default_session_duration)
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = local.managed_policy_map

  instance_arn       = local.sso_instance
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_name].arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = local.inline_policy_map

  inline_policy      = each.value
  instance_arn       = local.sso_instance
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
}

resource "aws_ssoadmin_account_assignment" "groups" {
  for_each = local.group_assignment_map

  instance_arn       = local.sso_instance
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_name].arn
  principal_id       = data.aws_identitystore_group.this[each.value.group_name].group_id
  principal_type     = "GROUP"
  target_id          = var.account_ids[each.value.account_name]
  target_type        = "AWS_ACCOUNT"
}

data "aws_identitystore_group" "this" {
  for_each = toset(keys(var.group_assignments))

  identity_store_id = local.identity_store

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value
    }
  }
}

data "aws_ssoadmin_instances" "this" {}
