SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

I         ?= $(SELF)/kub3lo.ini
INVENTORY ?= $(I)
NAME      := $(shell grep -oP '^cluster_name\s*=\s*\K\w+$$' $(INVENTORY))

export

.PHONY: all

all: kub3lo

.PHONY: kub3lo

kub3lo:
	cd $(SELF)/ && ansible-playbook -v -i $(INVENTORY) kub3lo.yml

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

.PHONY: metallb traefik

metallb: METALLB_CHART_VERSION ?= 0.12.1
metallb:
	cd $(SELF)/ && ANSIBLE_ROLES_PATH=$(SELF)/addons/ ansible \
	-e metallb_chart_version=$(METALLB_CHART_VERSION) \
	-m include_role -a name=metallb/deploy \
	-i $(INVENTORY) master

traefik: TRAEFIK_CHART_VERSION ?= 10.23.0
traefik:
	cd $(SELF)/ && ANSIBLE_ROLES_PATH=$(SELF)/addons/ ansible \
	-e traefik_chart_version=$(TRAEFIK_CHART_VERSION) \
	-m include_role -a name=traefik/deploy \
	-i $(INVENTORY) master
