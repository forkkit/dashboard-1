TAG ?= latest

ECR_REPO := 957571668058.dkr.ecr.us-west-2.amazonaws.com/dashboard
GIT_REVISION := $(shell git rev-parse HEAD)
GIT_SHORT := $(shell git rev-parse --short=12 HEAD)

.PHONY: all build run test test-nowatch release-cloud release-enterprise

all: run

build:
	docker build --pull -t faunadb-dashboard .

run: build
# Mount folders individually to use docker image's node_modules.
	docker run -it --rm -v "$(PWD)/config":/usr/src/app/config -v "$(PWD)/packages":/usr/src/app/packages -v "$(PWD)/public":/usr/src/app/public -v "$(PWD)/scripts":/usr/src/app/scripts --net=host faunadb-dashboard

test: build
	docker run -it --rm -v "$(PWD)/config":/usr/src/app/config -v "$(PWD)/packages":/usr/src/app/packages -v "$(PWD)/public":/usr/src/app/public -v "$(PWD)/scripts":/usr/src/app/scripts faunadb-dashboard npm run test

test-nowatch: build
# Set CI env to dummy value so watch is not enabled.
	docker run --rm -e CI=dummy -v "$(PWD)/config":/usr/src/app/config -v "$(PWD)/packages":/usr/src/app/packages -v "$(PWD)/public":/usr/src/app/public -v "$(PWD)/scripts":/usr/src/app/scripts faunadb-dashboard npm run test

release-cloud: test-nowatch
	docker build --pull -f Dockerfile.release --build-arg EDITION=cloud --build-arg REVISION=$(GIT_REVISION) -t $(ECR_REPO):$(GIT_SHORT)-cloud -t $(ECR_REPO):$(TAG)-cloud .
	docker push $(ECR_REPO):$(GIT_SHORT)-cloud
	docker push $(ECR_REPO):$(TAG)-cloud

release-enterprise: test-nowatch
	docker build --pull -f Dockerfile.release --build-arg EDITION=enterprise --build-arg REVISION=$(GIT_REVISION) -t $(ECR_REPO):$(GIT_SHORT)-enterprise -t $(ECR_REPO):$(GIT_SHORT) -t $(ECR_REPO):$(TAG)-enterprise -t $(ECR_REPO):$(TAG) .
	docker push $(ECR_REPO):$(GIT_SHORT)-enterprise
	docker push $(ECR_REPO):$(GIT_SHORT)
	docker push $(ECR_REPO):$(TAG)-enterprise
	docker push $(ECR_REPO):$(TAG)
