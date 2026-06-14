variable "namespace" {
  default = "portfolio"
}
variable "backend_image" {
  default = "cfaye876/portfolio-backend:latest"
}
variable "frontend_image" {
  default = "cfaye876/portfolio-frontend:latest"
}
variable "mongodb_image" {
  default = "mongo:4.4"
}
variable "frontend_nodeport" {
  default = 30081
}