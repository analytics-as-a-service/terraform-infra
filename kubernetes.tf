# resource "kubernetes_namespace" "confluent" {
#   metadata {
#     name = "confluent"
#   }
# }

# resource "kubernetes_manifest" "confluent_platform" {
#   depends_on = [
#     helm_release.confluent
#   ]
#   for_each = toset(fileset(".", "confluent/platform/*"))
#   manifest = yamldecode(templatefile(each.value, { namespace = "default" }))
#   wait {
#     condition {
#       type   = "Initialized"
#       status = "True"
#     }
#   }
# }

# resource "kubectl_manifest" "confluent_platform" {
#   yaml_body = templatefile("confluent/confluent-platform.yaml", { hdfs_service = locals.hdfs_service })
# }
