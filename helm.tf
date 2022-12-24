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

  set {
    name  = "kafka_topic"
    value = var.kafka_topic
  }
}

data "kubernetes_service" "hdfs_nn" {
  depends_on = [helm_release.hdfs]
  metadata {
    name = "${helm_release.hdfs.metadata[0].name}-${helm_release.hdfs.metadata[0].chart}-hdfs-nn"
  }
}

resource "helm_release" "data_warehouse" {
  name       = "data-warehouse"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"
  namespace  = var.namespace
  set {
    name  = "auth.username"
    value = "${var.mysql_username}"
  }
  set {
    name  = "auth.password"
    value = "${var.mysql_password}"
  }
  set {
    name  = "auth.rootPassword"
    value = "${var.mysql_root_password}"
  }
  set {
    name  = "auth.database"
    value = "${var.mysql_database}"
  }
}

resource "null_resource" "generate_dashboard" {
  triggers = {
      output_present = fileexists("superset/output.zip")
  }
  provisioner "local-exec" {
    command = "python3 update-dashboard.py root ${var.mysql_root_password} ${var.mysql_database} ${var.mysql_table} ${local.data_warehouse_release}-${local.data_warehouse_chart}"
    working_dir = "superset"
  }
}

resource "helm_release" "superset" {
  depends_on = [
    helm_release.data_warehouse,
    null_resource.generate_dashboard
  ]
  name       = "superset"
  chart     = "superset/superset"
  namespace = var.namespace

  values = [
    "${templatefile("superset/values.yaml", { dashboard = filebase64("superset/output.zip") })}"
  ]
}

resource "helm_release" "data_computation" {
  name       = "compute"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "spark"
  namespace  = var.namespace
  set {
    name  = "image.repository"
    value = "akhil15935/spark"
  }
  set {
    name  = "image.tag"
    value = "spark-ml-3.3.1"
  }
  set {
    name = "worker.replicaCount"
    value = 3
  }
}

resource "helm_release" "jupyterhub" {
  depends_on = [
    helm_release.data_computation,
    helm_release.data_warehouse,
    helm_release.confluent
  ]
  name       = "jupyterhub"
  repository = "https://jupyterhub.github.io/helm-chart/"
  chart      = "jupyterhub"
  namespace  = var.namespace
  set {
    name  = "singleuser.image.name"
    value = "akhil15935/spark-jupyter"
  }
  set {
    name  = "singleuser.image.tag"
    value = "spark-kafka-ml-3.3.1"
  }
  set {
    name  = "singleuser.storage.homeMountPath"
    value = "/opt/bitnami/jupyterhub-singleuser/"
  }
  set {
    name  = "proxy.service.type"
    value = "NodePort"
  }
  set {
    name  = "singleuser.extraEnv.MYSQL_USERNAME"
    value = "${var.mysql_username}"
  }
  set {
    name  = "singleuser.extraEnv.MYSQL_PASSWORD"
    value = "${var.mysql_password}"
  }
  set {
    name  = "singleuser.extraEnv.MYSQL_DATABASE"
    value = "${var.mysql_database}"
  }
  set {
    name  = "singleuser.extraEnv.MYSQL_TABLE"
    value = "${var.mysql_table}"
  }
  set {
    name  = "singleuser.extraEnv.KAFKA_TOPIC"
    value = "${var.kafka_topic}"
  }
}
