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
variable "mysql_username" {
  type = string
  default = "aaauser"
}
variable "mysql_password" {
  type = string
  default = "123123aasmysqlpass"
}
variable "mysql_root_password" {
  type = string
  default = "123123aasmysqlpass"
}
variable "mysql_database" {
  type = string
  default = "bank"
}
variable "mysql_table" {
  type = string
  default = "transactions"
}