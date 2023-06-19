SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

I         ?= $(SELF)/kub3lo.ini
INVENTORY ?= $(I)
NAME      := $(shell awk -F '[=:][[:space:]]*' '/[[:space:]]*cluster_name[[:space:]]*[=:]/ { print $$2 }' $(INVENTORY))

export

.PHONY: all

all: deploy

.PHONY: deploy

deploy:
	cd $(SELF)/ && ansible-playbook -v -i $(INVENTORY) sk4zuzu.kub3lo.$@

.PHONY: proxy

proxy:
	ssh -F $(SELF)/.ssh/config $(NAME)-proxy -N

.PHONY: kc kubeconfig

kc kubeconfig:
	@echo export KUBECONFIG=$(SELF)/.tmp/$(NAME)/kubeconfig

.PHONY: b become

b become:
	@: $(eval BECOME_ROOT := -t sudo -i)

ssh-%:
	@echo NOTICE: if you have complex hostnames use "\"ssh -F .ssh/config <tab>\"" auto-completion instead
	@ssh -F $(SELF)/.ssh/config $* $(BECOME_ROOT)
