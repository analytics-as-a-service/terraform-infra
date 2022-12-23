locals {
  hdfs_chart = helm_release.hdfs.metadata[0].chart
  hdfs_release = helm_release.hdfs.metadata[0].name
  hdfs_port = [for each in data.kubernetes_service.hdfs_nn.spec[0].port : each.port if each.name == "dfs"][0]
  hdfs_service = "hdfs://${local.hdfs_release}-${local.hdfs_chart}-hdfs-nn:${local.hdfs_port}"
}
