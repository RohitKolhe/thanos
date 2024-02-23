# Thanos (Prometheus) Tutorial: Remote write

# Foobar

This project demonstrates a demo for deploying Prometheus and connecting it with a Thanos as sidecar pattern, is deployed using Helm charts. Minio is utilized as the storage bucket for long-term storage of metrics data.

## Deployment

Create Kubernetes Namespace for Monitoring

```bash
kubectl apply -f helm-monitoring-ns.yaml
```

Minio for Storage

```bash
helm install minio-release oci://registry-1.docker.io/bitnamicharts/minio -n minio

# Get Minio Access Credentials
kubectl get secret --namespace minio minio-release -o jsonpath="{.data.root-user}" | base64 -d
kubectl get secret --namespace minio minio-release -o jsonpath="{.data.root-password}" | base64 -d

```

Prometheus

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prom-release -n helm-monitoring prometheus-community/kube-prometheus-stack -f prometheus/values.yaml
```

Grafana

```bash
helm install grafana bitnami/grafana --set service.type=LoadBalancer --set admin.password=admin -n helm-monitoring
```

## Deployment using make

```bash
make -f setup-monitoring.makefile 
```

# Troubleshooting

Port Forwarding

+ Minio:
```bash
kubectl port-forward --namespace helm-monitoring svc/minio-release 9001:9000
```

+ Prometheus
```bash
kubectl port-forward --namespace helm-monitoring svc/prom-release-kube-prometheus-prometheus 9091:9090
```

+ View Prometheus Logs
```bash
kubectl -n helm-monitoring logs -l app.kubernetes.io/name=prometheus -f
```
