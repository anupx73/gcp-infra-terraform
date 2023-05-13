output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "location" {
  description = "Cluster location"
  value       = module.gke.location
}

output "region" {
  description = "Cluster region"
  value       = module.gke.region
}

output "master_kubernetes_version" {
  description = "Cluster kubernetes version"
  value       = module.gke.master_version
}

output "backend_static_ip" {
  description = "Backend static ip"
  value       = google_compute_global_address.backend_ip.address
}

output "frontend_static_ip" {
  description = "Frontend static ip"
  value       = google_compute_global_address.frontend_ip.address
}