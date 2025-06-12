variable "RUSTACK_ENDPOINT" {
  description = "Rustack API Endpoint"
  type        = string
}

variable "RUSTACK_TOKEN" {
  description = "Rustack API Token"
  type        = string
}

variable "USER_LOGIN" {
  description = "User's login"
  type        = string
}

variable "CLUSTER_NAME" {
  description = "The prefix for the cluster name, e.g., 'kube01'. This will be combined with CLUSTER_TLD."
  type        = string
  default     = "kube01"
}

variable "CLUSTER_TLD" {
  description = "Cluster top level domain name, e.g example.com"
  type        = string
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
variable "STEP_PROVISIONER_AUTOCERT" {
  description = "StepCA kube provisioner name for autocert"
  type        = string
  default     = "autocert"
}

variable "STEP_PASSWORD_AUTOCERT" {
  description = "StepCA password file for autocert"
  type        = string
}


variable "STEP_STATIC_CLIENT_SECRET" {
  description = "StepCA static client secret"
  type        = string
}
variable "TEMPORAL_STATIC_CLIENT_SECRET" {
  description = "Teporal static client secret"
  type        = string
}
variable "TEMPORAL_DB_PASSWORD" {
  description = "Teporal DB password"
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


variable "POSTGRESQL_HOST" {
  description = "database server host for k3s"
  type        = string
}

variable "POSTGRESQL_PORT" {
  description = "database server port for k3s"
  type        = number
  default     = 5432
}

variable "DEX_DOMAIN" {
  description = "DEX_DOMAIN, e.g dex.example.com"
  type        = string
}
variable "GITHUB_CLIENT_ID" {
  description = "GITHUB_CLIENT_ID for DEX IDP"
  type        = string
}

variable "GITHUB_CLIENT_SECRET" {
  description = "GITHUB_CLIENT_SECRET for DEX IDP"
  type        = string
}

variable "HH_CLIENT_ID" {
  description = "HH_CLIENT_ID for DEX IDP"
  type        = string
}

variable "HH_CLIENT_SECRET" {
  description = "HH_CLIENT_SECRET for DEX IDP"
  type        = string
}

variable "PGADMIN4_EMAIL" {
  description = "PGADMIN4_EMAIL"
  type        = string
}


variable "PGADMIN4_PASSWORD" {
  description = "PGADMIN4_PASSWORD"
  type        = string
}

variable "OUTLINE_CLIENT_SECRET" {
  description = "OUTLINE_CLIENT_SECRET for DEX IDP"
  type        = string
}
variable "OUTLINE_DOMAIN" {
  description = "OUTLINE_DOMAIN, e.g docs.example.com"
  type        = string
}
