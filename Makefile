.PHONY: lint
lint:
	terraform -chdir=./terraform fmt -recursive 
	terraform -chdir=./terraform validate 

.PHONY: apply
apply:
	terraform -chdir=./terraform apply -auto-approve

.PHONY: destroy
destroy:
	helm delete otel-demo
	terraform -chdir=./terraform destroy -auto-approve

.PHONY: init
init:
	terraform -chdir=./terraform init

.PHONY: output
output:
	terraform -chdir=./terraform output