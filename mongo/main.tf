# atlas project
resource "mongodbatlas_project" "project" {
  name   = var.project_name
  org_id = var.org_id
}
output "project_name" {
  value = mongodbatlas_project.project.name
}

# atlas cluster
resource "mongodbatlas_cluster" "cluster" {
  project_id             = mongodbatlas_project.project.id
  name                   = var.cluster_name
  mongo_db_major_version = var.mongodbversion
  cluster_type           = "REPLICASET"
  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = var.region
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }
  # Provider Settings "block"
  cloud_backup                 = false
  auto_scaling_disk_gb_enabled = false
  provider_name                = var.cloud_provider
  provider_instance_size_name  = "M0"
}
output "connection_strings" {
  value = mongodbatlas_cluster.cluster.connection_strings[0].standard_srv
}

# db user create
resource "mongodbatlas_database_user" "user" {
  username           = var.dbuser
  password           = var.dbuser_password
  project_id         = mongodbatlas_project.project.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = var.database_name # The database name and collection name need not exist in the cluster before creating the user.
  }
  labels {
    key   = "Name"
    value = "DB User1"
  }
}
output "user1" {
  value = mongodbatlas_database_user.user.username
}

# ip access list
resource "mongodbatlas_project_ip_access_list" "ip" {
  project_id = mongodbatlas_project.project.id
  #ip_address = var.ip_address
  cidr_block = var.ip_address
  comment    = "IP Address for accessing the cluster"
}
output "ipaccesslist" {
  value = mongodbatlas_project_ip_access_list.ip.ip_address
}
