###############################
# Common defaults/definitions #
###############################

comma := ,

# Checks two given strings for equality.
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)




######################
# Project parameters #
######################

HARAKA_VER ?= $(strip \
	$(shell grep 'ARG haraka_ver=' Dockerfile | cut -d '=' -f2))
NODE_VER ?= $(strip \
	$(shell grep 'ARG node_ver=' Dockerfile | cut -d '=' -f2))
BUILD_REV ?= $(strip \
	$(shell grep 'ARG build_rev=' Dockerfile | cut -d '=' -f2))

NAMESPACES := instrumentisto \
              ghcr.io/instrumentisto \
              quay.io/instrumentisto
NAME := haraka
TAGS ?= $(HARAKA_VER)-node$(NODE_VER)-r$(BUILD_REV) \
        $(HARAKA_VER) \
        $(strip $(shell echo $(HARAKA_VER) | cut -d '.' -f1,2)) \
        $(strip $(shell echo $(HARAKA_VER) | cut -d '.' -f1)) \
        latest
VERSION ?= $(word 1,$(subst $(comma), ,$(TAGS)))
PLATFORMS ?= linux/amd64 \
             linux/arm64 \
             linux/arm/v6 \
             linux/arm/v7 \
             linux/ppc64le \
             linux/s390x
MAIN_PLATFORM ?= $(word 1,$(subst $(comma), ,$(PLATFORMS)))




###########
# Aliases #
###########

image: docker.image

push: docker.push

test: test.docker




###################
# Docker commands #
###################

docker-namespaces = $(strip $(if $(call eq,$(namespaces),),\
                            $(NAMESPACES),$(subst $(comma), ,$(namespaces))))
docker-tags = $(strip $(if $(call eq,$(tags),),\
                      $(TAGS),$(subst $(comma), ,$(tags))))
docker-platforms = $(strip $(if $(call eq,$(platforms),),\
                           $(PLATFORMS),$(subst $(comma), ,$(platforms))))

# Runs `docker buildx build` command allowing to customize it for the purpose of
# re-tagging or pushing.
define docker.buildx
	$(eval namespace := $(strip $(1)))
	$(eval tag := $(strip $(2)))
	$(eval platform := $(strip $(3)))
	$(eval no-cache := $(strip $(4)))
	$(eval args := $(strip $(5)))
	docker buildx build --force-rm $(args) \
		--platform $(platform) \
		$(if $(call eq,$(no-cache),yes),--no-cache --pull,) \
		--build-arg haraka_ver=$(HARAKA_VER) \
		--build-arg node_ver=$(NODE_VER) \
		--build-arg build_rev=$(BUILD_REV) \
		-t $(namespace)/$(NAME):$(tag) .
endef


# Pre-build cache for Docker image builds.
#
# WARNING: This command doesn't apply tag to the built Docker image, just
#          creates a build cache. To produce a Docker image with a tag, use
#          `docker.tag` command right after running this one.
#
# Usage:
#	make docker.build.cache
#		[platforms=($(PLATFORMS)|<platform-1>[,<platform-2>...])]
#		[no-cache=(no|yes)]
#		[HARAKA_VER=<haraka-version>]
#		[NODE_VER=<node-version>]
#		[BUILD_REV=<build-revision>]

docker.build.cache:
	$(call docker.buildx,\
		instrumentisto,\
		build-cache,\
		$(shell echo "$(docker-platforms)" | tr -s '[:blank:]' ','),\
		$(no-cache),\
		--output 'type=image$(comma)push=false')


# Build Docker image on the given platform with the given tag.
#
# Usage:
#	make docker.image
#		[tag=($(VERSIOM)|<tag>)]
#		[platform=($(MAIN_PLATFORM)|<platform>)]
#		[no-cache=(no|yes)]
#		[HARAKA_VER=<haraka-version>]
#		[NODE_VER=<node-version>]
#		[BUILD_REV=<build-revision>]

docker.image:
	$(call docker.buildx,\
		instrumentisto,\
		$(if $(call eq,$(tag),),$(VERSION),$(tag)),\
		$(if $(call eq,$(platform),),$(MAIN_PLATFORM),$(platform)),\
		$(no-cache),\
		--load)


# Push Docker images to their repositories (container registries),
# along with the required multi-arch manifests.
#
# Usage:
#	make docker.push
#		[namespaces=($(NAMESPACES)|<prefix-1>[,<prefix-2>...])]
#		[tags=($(TAGS)|<tag-1>[,<tag-2>...])]
#		[platforms=($(PLATFORMS)|<platform-1>[,<platform-2>...])]
#		[HARAKA_VER=<haraka-version>]
#		[NODE_VER=<node-version>]
#		[BUILD_REV=<build-revision>]

docker.push:
	$(foreach namespace,$(docker-namespaces),\
		$(foreach tag,$(docker-tags),\
			$(call docker.build,\
				$(namespace),\
				$(tag),\
				$(shell echo "$(docker-platforms)" | tr -s '[:blank:]' ','),,\
				--push)))




####################
# Testing commands #
####################

# Run Bats tests for Docker image.
#
# Documentation of Bats:
#	https://github.com/bats-core/bats-core
#
# Usage:
#	make test.docker
#		[tag=($(VERSIOM)|<tag>)]
#		[platforms=($(MAIN_PLATFORM)|@all|<platform-1>[,<platform-2>...])]
#		[( [build=no]
#		 | build=yes [HARAKA_VER=<haraka-version>]
#		             [NODE_VER=<node-version>]
#		             [BUILD_REV=<build-revision>] )]

test-docker-platforms = $(strip $(if $(call eq,$(platforms),),$(MAIN_PLATFORM),\
                                $(if $(call eq,$(platforms),@all),$(PLATFORMS),\
                                $(docker-platforms))))
test.docker:
ifeq ($(wildcard node_modules/.bin/bats),)
	@make npm.install
endif
	$(foreach platform,$(test-docker-platforms),\
		$(call test.docker.do,\
			$(if $(call eq,$(tag),),$(VERSION),$(tag)),\
			$(platform)))
define test.docker.do
	$(eval tag := $(strip $(1)))
	$(eval platform := $(strip $(2)))
	$(if $(call eq,$(build),yes),\
		@make docker.image no-cache=no tag=$(tag) platform=$(platform) \
			HARAKA_VER=$(HARAKA_VER) \
			NODE_VER=$(NODE_VER) \
			BUILD_REV=$(BUILD_REV) ,)
	IMAGE=instrumentisto/$(NAME):$(tag) PLATFORM=$(platform) \
	node_modules/.bin/bats --pretty --timing tests/main.bats
endef




################
# NPM commands #
################

# Resolve project NPM dependencies.
#
# Usage:
#	make npm.install
#		[dockerized=(no|yes)]

npm.install:
ifeq ($(dockerized),yes)
	docker run --rm --network=host -v "$(PWD)":/app/ -w /app/ \
		node:$(NODE_VER) \
			make npm.install dockerized=no
else
	npm install
endif




##################
# .PHONY section #
##################

.PHONY: image push test \
        docker.build.cache docker.image docker.push \
        npm.install \
        test.docker
