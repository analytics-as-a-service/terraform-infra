variable "namespace" {
  type = string
  default = "default"
}

variable "kube_config_path" {
  type = string
  default = "~/.kube/config"
}

variable "kube_config_context" {
  type = string
  default = "kubernetes-admin@kubernetes"
}

variable "kafka_topic" {
  type = string
  default = "transactions"
}