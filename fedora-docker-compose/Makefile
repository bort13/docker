IMAGE ?= fedora-dev
TAG ?= latest

build:
	docker compose build

shell:
	docker compose run --rm fedora-dev

shell-root:
	docker compose run --rm --user root fedora-dev

shell-net:
	docker compose run --rm --privileged fedora-dev

shell-priv:
	docker compose run --rm --privileged fedora-dev

clean:
	docker compose down --rmi all

.PHONY: build shell shell-root shell-net shell-priv clean
