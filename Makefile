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

.PHONY: dashboard
dashboard:
	terraform -chdir=./dashboard init && terraform -chdir=./dashboard apply -auto-approve -var="LIGHTSTEP_ORG=ap-k23-workshop" -var="LIGHTSTEP_API_KEY=$$LIGHTSTEP_API_KEY" -var="LIGHTSTEP_PROJECT=$$LIGHTSTEP_PROJECT"
