include .env

registry-up:
	k3d registry create datasil-registry --port 5050

k8s-up:
	k3d cluster create datasil --registry-use k3d-datasil-registry:5050

k8s-down:
	k3d cluster delete datasil

create-db:
	psql -c "createdb -h ${DB_HOST} -p ${DB_PORT} -E UTF8 -O postgres datasil;"

migration:
	@migrate create -ext sql -dir migrations $(filter-out $@,$(MAKECMDGOALS))

migrate-up:
	migrate -path=../datasil-api/migrations -database "postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -verbose up

migrate-down:
	migrate -path=../datasil-api/migrations -database "postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -verbose down