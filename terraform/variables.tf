variable "RUSTACK_ENDPOINT" {
  description = "Rustack API Endpoint"
  type        = string
}

variable "RUSTACK_TOKEN" {
  description = "Rustack API Token"
  type        = string
}

# variable "PUBLIC_KEY" {
#   description = "User's public key file path"
#   type        = string
# }

variable "USER_LOGIN" {
  description = "User's login"
  type        = string
}
variable "RUSTACK_SERVER_NODES" {
  type = list(object({
    cpu   = number
    ram   = number
    disk  = number
    power = bool
  }))
  default = [
    {
      cpu   = 8
      ram   = 16
      disk  = 160
      power = true
    }
  ]
}
variable "RUSTACK_AGENT_NODES" {
  type = list(object({
    cpu   = number
    ram   = number
    disk  = number
    power = bool
  }))
  default = [
    {
      cpu   = 8
      ram   = 16
      disk  = 160
      power = true
    }
  ]
}

variable "CLUSTER_DOMAIN" {
  description = "The prefix for the cluster name, e.g., 'kube01.icncd.ru'. This will be combined with CLUSTER_TLD."
  type        = string
}

variable "RUSTACK_SERVERS_NUM" {
  description = "Number of control plane nodes."
  default     = 1
}

variable "RUSTACK_AGENTS_NUM" {
  description = "Number of agent nodes."
  default     = 0
}

variable "RUSTACK_CLUSTER_POWER" {
  description = "Cluster power switch"
  type        = bool
  default     = true
}

variable "RUSTACK_AGENT_POWER" {
  description = "Agents power switch"
  type        = bool
  default     = true
}


variable "STEPPATH" {
  description = "StepCA config dir"
  type        = string
  default     = "/etc/step-ca"
}

variable "STEPCERTPATH" {
  description = "StepCA certs dir"
  type        = string
  default     = "/etc/step/certs"
}

variable "STEP_ROOT_CA_PATH" {
  description = "StepCA root ca path"
  type        = string
  default     = "/etc/step-ca/certs/root_ca.crt"
}

variable "STEP_CA_URL" {
  description = "StepCA STEP_CA_URL, e.g. https://ca.example.com:4443"
  type        = string
}


variable "STEP_FINGERPRINT" {
  description = "StepCA STEP_FINGERPRINT"
  type        = string
}

variable "STEP_PROVISIONER" {
  description = "StepCA provisioner name"
  type        = string
  default     = "userspw"
}

variable "STEP_PASSWORD_FILE" {
  description = "StepCA password file for TOKEN/CERTIFICATE issue"
  type        = string
}


variable "STEP_PROVISIONER_KUBE_CA" {
  description = "StepCA kube provisioner name for CA generation"
  type        = string
  default     = "kube-ca"
}

variable "STEP_PASSWORD_KUBE_CA" {
  description = "StepCA password file for CA generation"
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

variable "DNS_NUM" {
  description = "Number of dns records for servers (usually equals to SERVERS_NUM)."
  default     = 1
}
variable "REDIS_NUM" {
  description = "Number of redis servers."
  default     = 1
}
variable "MONGODB_NUM" {
  description = "Number of mongodb servers."
  default     = 1
}

variable "POSTGRESQL_NUM" {
  description = "Number of postgresql servers"
  default     = 1
}

variable "POSTGRESQL_HOST" {
  description = "database server host for k3s"
  type        = string
}

variable "K3S_DB_PORT" {
  description = "database server port for k3s"
  type        = number
  default     = 5432
}

variable "K3S_DB_NAME" {
  description = "database name for k3s"
  type        = string
  default     = "k3s"
}

variable "K3S_DB_USER" {
  description = "database user for k3s"
  type        = string
  default     = "k3s"
}

variable "ADD_DOMAIN" {
  type    = list(string)
  default = []
}

variable "CONTAINER_MIRROR" {
  description = "Public container registry mirror"
  default     = "https://mirror.gcr.io"
}

variable "CONTAINER_REGISTRY" {
  description = "Private container registry"
  default     = "ghcr.io"
}

variable "CONTAINER_REGISTRY_USERNAME" {
  description = "Private container registry user name"
}

variable "CONTAINER_REGISTRY_PASSWORD" {
  sensitive   = true
  description = "Private container registry password"
}


variable "MANUAL_SERVER_NODES" {
  description = "MANUAL_SERVER_NODES"
  default     = []
}


variable "MANUAL_AGENT_NODES" {
  description = "MANUALMANUAL_AGENT_NODES_SERVER_NODES"
  default     = []
}
