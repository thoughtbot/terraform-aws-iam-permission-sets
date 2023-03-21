variable "account_ids" {
  description = "Account ID for each account name referenced in an assignment"
  type        = map(string)
}

variable "default_session_duration" {
  description = "Session duration for permission sets without an explicit value"
  type        = string
}

variable "group_assignments" {
  description = "Permission sets to be assigned to each group and account"
  type        = map(map(list(string)))
}

variable "permission_sets" {
  description = "Permission sets which should be defined by this module"
  type = list(object({
    description      = string,
    inline_policy    = optional(string),
    managed_policies = list(string),
    name             = string,
    relay_state      = optional(string),
    session_duration = optional(string),
  }))
}
