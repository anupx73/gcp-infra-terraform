# Infrastructure Layer Details

This repo holds the IaC for creating infra layer to deploy and run `react-bpcalc-k8s` and `go-backend-k8s` microservices. The following infrastructure resources are considered to have cloud cost impact hence the provisioning will be done only on-demand basis.

- Kubernetes cluster on GCP to host microservices
- MongoDB Atlas cluster with GCP provider to host database
- GKE Ingress resource to allow public connections to microservices (Experimental)


## GCP Resource Provisioning

- Make sure the prerequisites are installed, i.e., GCloud SDK, Terraform, Kubectl, Helm, K9S on local system
- Config the GCP project and check if it is accessible from local system shell
  ```
  gcloud config configurations activate anupx73
  gcloud config get-value project
  gcloud auth application-default login
  ```
- Deploy GKE using terraform scripts from `./gke` folder; this takes about 25mins
- Note frontend and backend static ip from output; to be used as microservice public url
- Connect gcloud sdk on local system to newly created GKE cluster 
  ```
  gcloud container clusters get-credentials gke-stg --project tudublin --zone europe-west1-b
  ```

## MongoDB Atlas Provisioning
- Add the current system's public IP to Altas network access to allow terraform API access
- Deploy Mongo Atlas via terraform; takes ~10mins
- Note the Mongo Atlas url from output excluding `mongodb+srv://`; modify url to have `pri` to support vpc private connections (e.g. `atlas-stg-pri.xyz.mongodb.net`)
- Initiate VPC Peering from Atlas project > network access > peering; add gcp project name and vpc name
- Approve VPC Peering in GCP with atlas gcp project id and atlas vpc name
- Add GKE cluster pod ipv4 range (typically `10.96.0.0/14`) in Atlas network access > ip access list to allow private connection from GKE

## Vault Secret Management Setup
- Set up Vault on GKE using Hashicorp official helm chart
  ``` 
  helm repo add hashicorp https://helm.releases.hashicorp.com
  helm repo update
  helm install vault hashicorp/vault --set "server.dev.enabled=true"
  ```

- Add MongoDB Atlas url from Atlas terraform output and DB credentials from terrafirm.tfvars
  ```
  kubectl get pods
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

## Grafana Monitoring Setup
- Prometheus and Grafana stack can be setup on GKE cluster but for this project Grafana Cloud has been used for ease of operations, so the following is for reference only.
  ```
  # install prometheus community chart
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  helm install prometheus prometheus-community/kube-prometheus-stack
  kubectl get pods

  # prometheus dashboard access
  kubectl port-forward prometheus-prometheus-kube-prometheus-prometheus-0 8000:9090

  # grafana dahsboard access
  kubectl get svc
  kubectl port-forward kube-prometheus-stack-1606233825-grafana-598d4d4bd6-r7pp5 8000:3000
  open http://localhost:8000/login  # user: admin, pwd: prom-operation
  ```
- Set up Grafana Cloud monitoring for log collection
  ```
  curl -fsS https://raw.githubusercontent.com/grafana/loki/master/tools/promtail.sh | sh -s 596161 eyJrIjoiZWUyYjAyNWYyNGRiMzNhNjgwY2QwODY2MmUwNjQ4ZmRlNWFhOGEyNiIsIm4iOiJna2UgYWNjZXNzIiwiaWQiOjg1NTYwOH0= logs-prod-eu-west-0.grafana.net default | kubectl apply --namespace=default -f  -
  ```

## Continuous Deployment

Now that infrastructure layer has been up, CI/CD pipelines can be executed to deploy microservices. Please note currently the frontend and backend microservices are exposed by individual LoadBalancer IPs, hence the connection between them is managed from `./src/config.json` file in `react-bpcalc-k8s` repo. The backend service `go-backend-k8s` reads the mongo url from Vault hence no configuration is required. Once the infra layer is up and static IPs are configured, make sure the frontend-ip is assigned in `./src/config.json`.

## Canary Deployment



## Miscellaneous 
**Experimental Ingress Config**
  ```
  # install gce ingress (controller provider by GCP) 
  helm install ingress ./gke-ingress

  # nginx ingress useful annotations
  kubernetes.io/ingress.class: "nginx"
  nginx.ingress.kubernetes.io/rewrite-target: /$2
  nginx.ingress.kubernetes.io/use-regex: "true"  
  ```
