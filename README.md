# Infrastructure Provisioning for Microservices

This repo holds the terraform and helm chart code for creating:
- Kubernetes cluster on GCP to host microservices
- MongoDB Atlas cluster with GCP provider to host database
- GKE Ingress resource to allow public connections to microservices

Both of these infrastructure are considered to have cloud cost impact hence the provisioning will be done only on demand basis

## Steps to Follow

- Make sure the GCP project is accessible using GCloud SDK
  ```
  gcloud config configurations activate anupx73
  gcloud config get-value project
  gcloud auth application-default login
  ```
- Deploy GKE via terraform; takes ~25mins
- Note the Cluster ingress ip from output; to be used as microservice public url
- Add the current system IP to Altas network access to allow terraform API access
- Deploy Mongo Atlas via terraform; takes ~10mins
- Note the Mongo Atlas url from output; only the host name excluding `mongodb+srv://`
- Initiate VPC Peering from Atlas project > network access > peering; add gcp project name and vpc name
- Approve VPC Peering in GCP with atlas gcp project id and atlas vpc name
- Add GKE cluster pod ipv4 address in Atlas network access > ip access list to allow private connection from GKE
- Setup Vault on GKE using helm; add Mongo Atlas url, credentails as secrets to Vault
  ```
  # to stay connected with GKE cluster 
  gcloud container clusters get-credentials gke-stg --project tudublin --zone europe-west1-b
  
  # vault install on GKE
  helm repo add hashicorp https://helm.releases.hashicorp.com
  helm repo update
  helm install vault hashicorp/vault --set "server.dev.enabled=true"

  # set secrets - put mongodb url from Atlas terraform output; credential from terrafirm.tfvars
  kubectl exec -it vault-0 -- /bin/sh
  vault secrets enable -path=internal kv-v2
  vault kv put internal/database/config username="" password="" url=""
  vault kv get internal/database/config
  vault auth enable kubernetes
  vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
  vault policy write internal-app - <<EOF
  path "internal/data/database/config" {
    capabilities = ["read"]
  }
  EOF
  vault write auth/kubernetes/role/internal-app \
      bound_service_account_names=internal-app \
      bound_service_account_namespaces=default \
      policies=internal-app \
      ttl=48h

  exit
  ```
- Run CI/CD pipelines to deploy microservices
- Create GKE ingress object by
  ```
  helm install ingress .
  ```

## Experimental Nginx Ingress
  ```
  # nginx ingress
  kubernetes.io/ingress.class: "nginx"
  nginx.ingress.kubernetes.io/rewrite-target: /$2
  nginx.ingress.kubernetes.io/use-regex: "true"

  # gce (current one)
  kubernetes.io/ingress.class: gce
  kubernetes.io/ingress.global-static-ip-name: {{ .Values.ingress.gke_static_ip }}
  ```
