# Makefile for setting up Kubernetes Monitoring

.DEFAULT_GOAL := setup-monitoring

.PHONY: setup-monitoring
setup-monitoring: create-namespace-and-secrets install-prometheus install-thanos install-grafana

.PHONY: create-namespace
create-namespace-and-secrets:
	kubectl apply -f helm-monitoring-ns.yaml
	kubectl apply -f objectstore.yaml

.PHONY: install-minio
install-minio:
	helm install minio-release oci://registry-1.docker.io/bitnamicharts/minio -n minio

.PHONY: get-minio-credentials
get-minio-credentials:
	@echo "Minio Access Credentials:"
	kubectl get secret --namespace minio minio-release -o jsonpath="{.data.root-user}" | base64 -d
	@echo
	@echo "Minio Secret Credentials:"
	kubectl get secret --namespace minio minio-release -o jsonpath="{.data.root-password}" | base64 -d

.PHONY: install-prometheus
install-prometheus:
	helm install  prom-release -n helm-monitoring -f prometheus/values_kube_prometheus.yaml bitnami/kube-prometheus

.PHONY: install-thanos
install-thanos:
	helm install thanos-release oci://registry-1.docker.io/bitnamicharts/thanos -f thanos/values.yaml -n helm-monitoring

.PHONY: install-grafana
install-grafana:
	helm install grafana bitnami/grafana --set service.type=LoadBalancer --set admin.password=admin -n helm-monitoring
