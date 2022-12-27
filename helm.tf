resource "helm_release" "hdfs" {
  name             = "hadoop"
  chart            = "hdfs/hadoop"
  namespace        = var.namespace
  create_namespace = true
  timeout = var.helm_timeout

  values = [
    "${templatefile("hdfs/values.yaml", { model = filebase64("hdfs/model.tar"), modeldir = var.modeldir, dataset_url = var.dataset_url, dataset_dir = var.dataset_dir })}"
  ]
}

resource "helm_release" "confluent_operator" {
  name             = "confluent-operator"
  repository       = "https://packages.confluent.io/helm/"
  chart            = "confluent-for-kubernetes"
  namespace        = var.namespace
  create_namespace = true
}

resource "helm_release" "confluent" {
  depends_on = [
    helm_release.confluent_operator
  ]
  name             = "confluent"
  chart            = "confluent/confluent"
  namespace        = var.namespace
  create_namespace = true
  timeout = var.helm_timeout

  set {
    name  = "hdfs_service"
    value = local.hdfs_service
  }

  set {
    name  = "kafka_topic"
    value = var.kafka_topic
  }
}

resource "helm_release" "data_warehouse" {
  name             = "data-warehouse"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "mysql"
  namespace        = var.namespace
  create_namespace = true
  timeout = var.helm_timeout
  set {
    name  = "auth.username"
    value = var.mysql_username
  }
  set {
    name  = "auth.password"
    value = var.mysql_password
  }
  set {
    name  = "auth.rootPassword"
    value = var.mysql_root_password
  }
  set {
    name  = "auth.database"
    value = var.mysql_database
  }
}

resource "null_resource" "generate_dashboard" {
  provisioner "local-exec" {
    command     = "python3 update-dashboard.py root ${var.mysql_root_password} ${var.mysql_database} ${var.mysql_table} ${local.data_warehouse_release}-${local.data_warehouse_chart}"
    working_dir = "superset"
  }
}

data "local_file" "dashboard" {
  filename = "superset/output.zip"
  depends_on = [
    null_resource.generate_dashboard
  ]
}

resource "helm_release" "superset" {
  depends_on = [
    helm_release.data_warehouse
  ]
  name             = "superset"
  chart            = "superset/superset"
  namespace        = var.namespace
  create_namespace = true
  timeout = var.helm_timeout

  values = [
    "${templatefile("superset/values.yaml", { dashboard = "${data.local_file.dashboard.content_base64}", slack_api = var.slack_api })}"
  ]
}

resource "helm_release" "data_computation" {
  name             = "compute"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "spark"
  namespace        = var.namespace
  create_namespace = true
  timeout = var.helm_timeout
  set {
    name  = "image.repository"
    value = "akhil15935/spark"
  }
  set {
    name  = "image.tag"
    value = "spark-ml-3.3.1"
  }
  set {
    name  = "worker.replicaCount"
    value = 3
  }
}

resource "helm_release" "jupyterhub" {
  depends_on = [
    helm_release.hdfs,
    helm_release.data_computation,
    helm_release.data_warehouse,
    helm_release.confluent
  ]
  timeout = var.helm_timeout
  name             = "jupyterhub"
  repository       = "https://jupyterhub.github.io/helm-chart/"
  chart            = "jupyterhub"
  namespace        = var.namespace
  create_namespace = true
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
    value = var.mysql_username
  }
  set {
    name  = "singleuser.extraEnv.MYSQL_PASSWORD"
    value = var.mysql_password
  }
  set {
    name  = "singleuser.extraEnv.MYSQL_DATABASE"
    value = var.mysql_database
  }
  set {
    name  = "singleuser.extraEnv.MYSQL_TABLE"
    value = var.mysql_table
  }
  set {
    name  = "singleuser.extraEnv.KAFKA_TOPIC"
    value = var.kafka_topic
  }
  set {
    name  = "singleuser.extraEnv.DATASET_LOCATION"
    value = var.dataset_dir
  }
  set {
    name  = "singleuser.extraEnv.MODEL_LOCATION"
    value = var.model_location
  }
  set {
    name  = "singleuser.extraEnv.PIPELINE_LOCATION"
    value = var.pipeline_location
  }
}

resource "helm_release" "compute_warehouse_integration" {
  depends_on = [
    helm_release.hdfs,
    helm_release.data_computation,
    helm_release.data_warehouse,
    helm_release.confluent
  ]
  timeout = var.helm_timeout
  name             = "compute-warehouse-integration"
  chart            = "compute-warehouse-integration"
  namespace        = var.namespace
  create_namespace = true
  set { 
    name = "MYSQL_USERNAME"
    value = var.mysql_username
  }
  set { 
    name = "MYSQL_PASSWORD"
    value = var.mysql_password
  }
  set { 
    name = "MYSQL_DATABASE"
    value = var.mysql_database
  }
  set { 
    name = "MYSQL_TABLE"
    value = var.mysql_table
  }
  set { 
    name = "KAFKA_TOPIC"
    value = var.kafka_topic
  }
  set { 
    name = "MODEL_LOCATION"
    value = var.model_location
  }
  set { 
    name = "PIPELINE_LOCATION"
    value = var.pipeline_location
  }
}
