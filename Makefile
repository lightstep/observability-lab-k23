.PHONY: lint
lint:
	terraform -chdir=./terraform fmt -recursive 
	terraform -chdir=./terraform validate 

.PHONY: apply
apply:
	terraform -chdir=./terraform apply -auto-approve

.PHONY: destroy
destroy:
	terraform -chdir=./terraform destroy -auto-approve

.PHONY: init
init:
	terraform -chdir=./terraform init