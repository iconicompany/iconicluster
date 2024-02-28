variable "rustack_endpoint" {
  description = "Rustack API Endpoint"
  type        = string
}

variable "rustack_token" {
  description = "Rustack API Token"
  type        = string
}

# variable "public_key" {
#   description = "User's public key file path"
#   type        = string
# }

# variable "public_key_rsa" {
#   description = "User's public key rsa file path"
#   type        = string
# }

variable "USER_LOGIN" {
  description = "User's login"
  type        = string
}

variable "CLUSTER_DOMAIN" {
  description = "Cluster domain name"
  type        = string
}

variable "SERVERS_NUM" {
  description = "Number of control plane nodes."
  default     = 1
}

variable "AGENTS_NUM" {
  description = "Number of agent nodes."
  default     = 1
}

variable "CLUSTER_POWER" {
  description = "Power switch"
  type        = bool
  default     = true
}


variable "STEPPATH" {
  description = "StepCA config dir"
  type        = string
  default     = "/etc/step-ca"
}


variable "STEP_CA_URL" {
  description = "StepCA STEP_CA_URL"
  type        = string
}


variable "STEP_FINGERPRINT" {
  description = "StepCA STEP_FINGERPRINT"
  type        = string
}

variable "STEP_PROVISIONER" {
  description = "StepCA provisioner name"
  type        = string
  default     = "users"
}

variable "STEP_PASSWORD_FILE" {
  description = "StepCA password file for TOKEN/CERTIFICATE issue"
  type        = string
}

variable "STEP_PROVISIONER_KUBE" {
  description = "StepCA kube provisioner name"
  type        = string
  default     = "kube"
}

variable "STEP_PASSWORD_KUBE" {
  description = "StepCA password file for TOKEN/CERTIFICATE issue"
  type        = string
}

variable "SSH_HOST_CA_FILE" {
  description = "StepCA host SSH CA"
  type        = string
  default     = "/etc/step-ca/certs/ssh_host_ca_key.pub"
}

variable "SSH_USER_CA_FILE" {
  description = "StepCA user SSH CA"
  type        = string
  default     = "/etc/step-ca/certs/ssh_user_ca_key.pub"
}

variable "GENERATE_K3S_STEP_CA" {
  description = "Generate k3s CA using Step-CA"
  type        = bool
  default     = true
}

variable "CLUSTER_ISSUER_EMAIL" {
  description = "Letsencrypt email"
  type        = string
}

variable "CLUSTER_SERVER" {
  type = list(object({
    cpu  = number
    ram  = number
    disk = number
  }))
  default = [
    {
      cpu  = 2
      ram  = 2
      disk = 60
    }
  ]
}
variable "CLUSTER_GRANT_ROLE" {
  description = "Grant role for user after cluster install"
  type        = string
  default     = "cluster-admin"
}

variable "CLUSTER_CA_CERTIFICATE" {
  description = "Path to PEM-encoded root certificates bundle for TLS"
  type        = string
  default     = "/etc/step-ca/certs/root_ca.crt"
}
variable "CLIENT_CERTIFICATE" {
  description = "Path to PEM-encoded client certificate for TLS authentication"
  type        = string
}

variable "CLIENT_KEY" {
  description = "Path to PEM-encoded client certificate key for TLS authentication"
  type        = string
}
