SHELL := /bin/sh
TF_DIR := infrastructure/terraform/environments/dev

.PHONY: up down logs backend frontend collector-logs test smoke-test aws-up aws-down tf-init tf-fmt tf-validate tf-plan tf-apply tf-destroy tf-output

up:
	-docker compose stop collector-s3
	docker compose up -d postgres backend frontend collector

down:
	docker compose --profile aws down

logs:
	docker compose logs -f

backend:
	docker compose logs -f backend

frontend:
	docker compose logs -f frontend

collector-logs:
	docker compose logs -f collector collector-s3

test:
	docker compose exec backend php artisan test
	docker compose exec frontend npm run build

smoke-test:
	./tests/smoke.sh

aws-up:
	-docker compose stop collector
	@bucket="$${AWS_S3_BUCKET:-$$(terraform -chdir=$(TF_DIR) output -raw s3_bucket_name)}"; \
	region="$${AWS_REGION:-$$(terraform -chdir=$(TF_DIR) output -raw aws_region)}"; \
	AWS_S3_BUCKET="$$bucket" AWS_REGION="$$region" docker compose --profile aws up -d postgres backend frontend collector-s3

aws-down:
	docker compose stop collector-s3

tf-init:
	terraform -chdir=$(TF_DIR) init

tf-fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

tf-validate:
	terraform -chdir=$(TF_DIR) validate

tf-plan:
	terraform -chdir=$(TF_DIR) plan

tf-apply:
	terraform -chdir=$(TF_DIR) apply

tf-destroy:
	terraform -chdir=$(TF_DIR) destroy

tf-output:
	terraform -chdir=$(TF_DIR) output
