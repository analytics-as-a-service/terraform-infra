provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}

provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_config_context
}
