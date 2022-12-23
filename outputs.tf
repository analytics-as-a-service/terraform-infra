output "service" {
    value = toset(fileset(".", "confluent/platform/*"))
}