terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}
# ─── NAMESPACE ─────────────────────────────────────
resource "kubernetes_namespace" "portfolio" {
  metadata {
    name = var.namespace
  }
}
# ─── MONGODB ───────────────────────────────────────
resource "kubernetes_deployment" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "mongodb" }
    }
    template {
      metadata {
        labels = { app = "mongodb" }
      }
      spec {
        container {
          name  = "mongodb"
          image = var.mongodb_image
          port { container_port = 27017 }
          volume_mount {
            name       = "mongo-data"
            mount_path = "/data/db"
          }
        }
        volume {
          name = "mongo-data"
          empty_dir {}
        }
      }
    }
  }
}
resource "kubernetes_service" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }
  spec {
    selector = { app = "mongodb" }
    port {
      port        = 27017
      target_port = 27017
    }
  }
}
# ─── BACKEND ───────────────────────────────────────
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "backend" }
    }
    template {
      metadata {
        labels = { app = "backend" }
      }
      spec {
        container {
          name  = "backend"
          image = var.backend_image
          port { container_port = 5000 }
          env {
            name  = "MONGODB_URI"
            value = "mongodb://mongodb:27017/portfolio"
          }
          env {
            name  = "PORT"
            value = "5000"
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }
  spec {
    selector = { app = "backend" }
    port {
      port        = 5000
      target_port = 5000
    }
  }
}
# ─── FRONTEND ──────────────────────────────────────
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "frontend" }
    }
    template {
      metadata {
        labels = { app = "frontend" }
      }
      spec {
        container {
          name  = "frontend"
          image = var.frontend_image
          port { container_port = 80 }
        }
      }
    }
  }
}
resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }
  spec {
    selector = { app = "frontend" }
    type     = "NodePort"
    port {
      port        = 80
      target_port = 80
      node_port   = var.frontend_nodeport
    }
  }
}