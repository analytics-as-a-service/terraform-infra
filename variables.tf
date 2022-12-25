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

variable "slack_api" {
  type = string
}

variable "modeldir" {
  type = string
  default = "/model"
}

variable "dataset_url" {
  type = string
  default = "https://storage.googleapis.com/kaggle-competitions-data/kaggle-v2/14242/568274/bundle/archive.zip?GoogleAccessId=web-data@kaggle-161607.iam.gserviceaccount.com&Expires=1672203339&Signature=dzm%2Bliy1DxFJxLBERezgVHWBPDd%2FmENle03MSqBsMe7sw1bp%2BIimAA9ZATqq7suJab%2FRws76RsF3RdZMxHBmDS6KqiCHRhPU8iKa0IPVK5pzifwB4WTEh2RG1luComULLcw25A4bdBQp5M3HK45cdv2jwj7%2FwL23sE9JdGu9fAEaFRd1LYCqUClB%2FGsZQEBpFEZiPWWCg%2FGfoFVfXFKCae50KfQZMv3bZGFq8u7f32duI%2FkFtubxK8JSA3YtvYOIZP4S8cupHI9T%2Flh5ABKN6NrcCmATkDvqhREQxZDnZ4BrR3beQPDU7UgiUx5D64EjS92Ziu%2B3Qbt1UZEQWmvMSQ%3D%3D&response-content-disposition=attachment%3B+filename%3Dieee-fraud-detection.zip"
}

variable "dataset_dir" {
  type = string
  default = "/data"
}

variable "model_location" {
  type = string
  default = "/model/model"
}

variable "pipeline_location" {
  type = string
  default = "/model/pipeline"
}

variable "helm_timeout" {
  type = number
  default = 600
}