output "namespace" {
  value = kubernetes_namespace.portfolio.metadata[0].name
}
output "frontend_nodeport" {
  value = "http://$(minikube ip):30080"
  description = "URL d'accès au frontend"
}
output "backend_service" {
  value = kubernetes_service.backend.metadata[0].name
}
output "mongodb_service" {
  value = kubernetes_service.mongodb.metadata[0].name
}