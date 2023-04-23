variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "tudublin"
}

variable "cluster_name" {
  description = "The default cluster name"
  default     = "gke-stg"
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "europe-west1"
}

variable "zones" {
  type        = list(string)
  description = "The zones to create the cluster."
  default     = [ "europe-west1-b" ]
}

variable "kubernetes_version" {
  description = "The initial version of GKE - If release_channel is supplied and auto update "
  default = "latest"
}

variable "release_channel" {
  description = "Release channel for GKE"
  default     = "STABLE"
}

variable "ip_range_pods" {
  description = "The secondary ip range to use for pods"
}

variable "ip_range_services" {
  description = "The secondary ip range to use for services"
}

variable "service_account" {
  description = "Service account to associate to the nodes in the cluster"
  default = "gke-staging@tudublin.iam.gserviceaccount.com"
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
  default     = "e2-small"
}

variable "min_count" {
  type        = number
  description = "Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count."
  default     = 2
}

variable "max_count" {
  type        = number
  description = "Maximum number of nodes in the NodePool. Must be >= min_node_count."
  default     = 4
}

variable "disk_size_gb" {
  type        = number
  description = "Size of the node's disk."
  default     = 10
}

variable "initial_node_count" {
  type        = number
  description = "The number of nodes to create in this cluster's default node pool."
  default     = 2
}
