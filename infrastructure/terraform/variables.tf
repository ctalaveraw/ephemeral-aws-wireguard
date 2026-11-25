variable "expected_account_id" {
  description = "Actual AWS Organizations MEMBER account ID; never the organization management account."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id)) && var.expected_account_id != "000000000000"
    error_message = "Provide a real 12-digit member account ID, not the example placeholder."
  }
}

variable "aws_region" {
  description = "MVP region. Intentionally limited to us-east-1 until a region change is reviewed."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "The initial MVP is approved only for us-east-1."
  }
}

variable "instance_type" {
  description = "Small ARM64 instance. 0.5 GiB t4g.nano is sufficient for SSH-only MVP."
  type        = string
  default     = "t4g.nano"

  validation {
    condition     = contains(["t4g.nano", "t4g.micro"], var.instance_type)
    error_message = "MVP limits instances to t4g.nano or t4g.micro."
  }
}

variable "operator_ssh_cidr" {
  description = "One PUBLIC IPv4 /32 belonging to the current operator (not 0.0.0.0/0)."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.operator_ssh_cidr)) && endswith(var.operator_ssh_cidr, "/32") && var.operator_ssh_cidr != "0.0.0.0/32"
    error_message = "Specify one operator IPv4 address with /32; never a broad CIDR."
  }
}

variable "operator_ssh_public_key" {
  description = "Only the public part of a locally stored SSH Ed25519 identity. Never pass private keys."
  type        = string

  validation {
    condition     = can(regex("^ssh-ed25519 [A-Za-z0-9+/=]+( .*)?$", trimspace(var.operator_ssh_public_key)))
    error_message = "Provide an OpenSSH ssh-ed25519 PUBLIC key."
  }
}

variable "session_id" {
  description = "Short unique label for this disposable session (one Terraform state per session)."
  type        = string
  default     = "mvp01"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,19}$", var.session_id))
    error_message = "Use 3-20 lowercase letters, digits or hyphens; start with a letter."
  }
}
