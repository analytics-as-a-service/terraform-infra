data "kubernetes_service" "hdfs_nn" {
  depends_on = [helm_release.hdfs]
  metadata {
    namespace = var.namespace
    name = "${helm_release.hdfs.metadata[0].name}-${helm_release.hdfs.metadata[0].chart}-hdfs-nn"
  }
}

