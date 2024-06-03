include .env

registry-up:
	k3d registry create datasil-registry --port 5050

k8s-up:
	k3d cluster create datasil --registry-use k3d-datasil-registry:5050

k8s-down:
	k3d cluster delete datasil