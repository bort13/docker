IMAGE ?= fedora-dev
TAG ?= latest

build:
	podman build -t $(IMAGE):$(TAG) ..

shell:
	podman run --rm -it $(IMAGE):$(TAG) /bin/bash

shell-root:
	podman run --rm -it --user root $(IMAGE):$(TAG) /bin/bash

shell-net:
	podman run --rm -it --cap-add NET_RAW $(IMAGE):$(TAG) /bin/bash

shell-priv:
	podman run --rm -it --privileged $(IMAGE):$(TAG) /bin/bash

clean:
	podman rmi $(IMAGE):$(TAG)

.PHONY: build shell shell-root clean
