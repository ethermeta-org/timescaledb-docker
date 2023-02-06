NAME=timescaledb-docker
# Default is to timescaledev to avoid unexpected push to the main repo
# Set ORG to timescale in the caller
ORG=masami10
PG_VER=pg12
PG_VER_NUMBER=$(shell echo $(PG_VER) | cut -c3-)

TS_VERSION=main
PREV_TS_VERSION=$(shell wget --quiet -O - https://raw.githubusercontent.com/timescale/timescaledb/${TS_VERSION}/version.config | grep update_from_version | sed -e 's!update_from_version = !!')
PREV_TS_IMAGE="$(ORG)/$(NAME):$(PREV_TS_VERSION)-pg$(PG_VER_NUMBER)-repmgr-bitnami"
PREV_IMAGE=$(shell if docker pull $(PREV_TS_IMAGE) >/dev/null; then echo "$(PREV_TS_IMAGE)"; else echo "bitnami/postgresql-repmgr:$(PG_VER_NUMBER)"; fi )

# Beta releases should not be tagged as latest, so BETA is used to track.
BETA=$(findstring rc,$(TS_VERSION))
TAG_VERSION=$(ORG)/$(NAME):$(TS_VERSION)-$(PG_VER)-repmgr-bitnami
TAG_LATEST=$(ORG)/$(NAME):latest-$(PG_VER)-repmgr-bitnami
TAG=-t $(TAG_VERSION) $(if $(BETA),,-t $(TAG_LATEST))

default: image

.build_$(TS_VERSION)_$(PG_VER): Dockerfile
	test -n "$(TS_VERSION)"  # TS_VERSION
	test -n "$(PREV_TS_VERSION)"  # PREV_TS_VERSION
	docker build -f ./Dockerfile --build-arg PG_VERSION=$(PG_VER_NUMBER) --build-arg TS_VERSION=$(TS_VERSION) --build-arg PREV_IMAGE=$(PREV_IMAGE) $(TAG) ..
	touch .build_$(TS_VERSION)_$(PG_VER)-repmgr-bitnami

image: .build_$(TS_VERSION)_$(PG_VER)

push: image
	docker push $(TAG_VERSION)
	if [ -z "$(BETA)" ]; then \
		docker push $(TAG_LATEST); \
	fi

clean:
	rm -f *~ .build_*

.PHONY: default image push clean
