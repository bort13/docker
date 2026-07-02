IMAGE ?= fedora-dev
TAG ?= latest

build:
	docker build -t $(IMAGE):$(TAG) ..

shell:
	docker run --rm -it $(IMAGE):$(TAG) /bin/bash

shell-root:
	docker run --rm -it --user root $(IMAGE):$(TAG) /bin/bash

clean:
	docker rmi $(IMAGE):$(TAG)

.PHONY: build shell shell-root clean
