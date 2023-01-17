#!/bin/bash
microk8s.kubectl apply -f aiidalab-storage.yml
microk8s.helm3 repo add jupyterhub https://jupyterhub.github.io/helm-chart/
microk8s.helm3 repo update
microk8s.helm3 upgrade aiidalab \
	jupyterhub/jupyterhub \
	--version=2.0.0 \
	--values values.yml \
	--cleanup-on-fail \
	--install $@
