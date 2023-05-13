variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "cluster_name" {
  description = "The default cluster name"
}

variable "region" {
  description = "The region to host the cluster in"
}

variable "zones" {
  type        = list(string)
  description = "The zones to create the cluster."
}

variable "kubernetes_version" {
  description = "The initial version of GKE - If release_channel is supplied and auto update "
}

variable "release_channel" {
  description = "Release channel for GKE"
}

variable "frontend_ip_name" {
  description = "The static ip to be used by frontend service LoadBalancer"
}

variable "backend_ip_name" {
  description = "The static ip to be used by backend service LoadBalancer"
}

variable "subnet_ip_range" {
  description = "The ip range for vpc subnet"
}

variable "ip_range_pods" {
  description = "The ip range to use for GKE pods"
}

variable "ip_range_services" {
  description = "The ip range to use for GKE services"
}

variable "ip_range_secondary" {
  description = "The secondary ip range to use for cluster"
}

variable "service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "skip_provisioners" {
  type        = bool
  description = "Flag to skip local-exec provisioners"
  default     = false
}

variable "enable_binary_authorization" {
  description = "Enable BinAuthZ Admission controller"
  default     = false
}

variable "machine_type" {
  type        = string
  description = "Type of the node compute engines."
}

variable "min_count" {
  type        = number
  description = "Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count."
}

variable "max_count" {
  type        = number
  description = "Maximum number of nodes in the NodePool. Must be >= min_node_count."
}

variable "disk_size_gb" {
  type        = number
  description = "Size of the node's disk."
}

variable "initial_node_count" {
  type        = number
  description = "The number of nodes to create in this cluster's default node pool."
}
