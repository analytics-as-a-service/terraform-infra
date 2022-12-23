resource "helm_release" "hdfs" {
  name      = "hadoop1"
  chart     = "hdfs/hadoop"
  namespace = var.namespace

  values = [
    "${file("hdfs/values.yaml")}"
  ]
}

resource "helm_release" "confluent_operator" {
  name       = "confluent-operator"
  repository = "https://packages.confluent.io/helm/"
  chart      = "confluent-for-kubernetes"
  namespace  = var.namespace
}

resource "helm_release" "confluent" {
  depends_on = [
    helm_release.confluent_operator
  ]
  name      = "confluent"
  chart     = "confluent/confluent"
  namespace = var.namespace

  set {
    name  = "hdfs_service"
    value = local.hdfs_service
  }
}

data "kubernetes_service" "hdfs_nn" {
  depends_on = [helm_release.hdfs]
  metadata {
    name = "${helm_release.hdfs.metadata[0].name}-${helm_release.hdfs.metadata[0].chart}-hdfs-nn"
  }
}

resource "helm_release" "superset" {
  name       = "superset"
  repository = "http://apache.github.io/superset/"
  chart      = "superset"
  namespace  = var.namespace
}
