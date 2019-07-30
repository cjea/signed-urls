k ?= /keybase/team/lrnexus/signed-url-svc-user-private-key.pem
b ?= gs://signed-url-testing

url:  ## generate signed url (pass keyfile with k=<PATH> and/or bucket name with b=<BUCKET>)
	@gsutil signurl -r us-central1 -d 10m -m PUT $(k) $(b)

in ?= "./info"
url-custom:  ## create a custom url (e.g make url-custom in=<<EOF ...)
	$(shell awk -f parse.awk $(in))

# Terminal color codes.
BLUE := $(shell tput setaf 4)
RESET := $(shell tput sgr0)
help: ## List all targets and short descriptions of each
	@grep -E '^[^ .]+: .*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk '\
			BEGIN { FS = ": .*##" };\
			{ printf "$(BLUE)%-29s$(RESET) %s\n", $$1, $$2  }'
