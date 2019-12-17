DOCKER_IMAGE_TAG = pim-helpcenter:master
DOCKER_RUN = docker run -it --rm -u "$${UID}":"$${GID}" -v "$${PWD}":/opt/workdir -w /opt/workdir

.PHONY: docker-build yarn-install serve deploy-staging
.DEFAULT_GOAL := build

docker-build:
	docker build -t $(DOCKER_IMAGE_TAG) .

yarn-install: docker-build
	$(DOCKER_RUN) $(DOCKER_IMAGE_TAG) yarn install

watch: yarn-install
	$(DOCKER_RUN) --expose=8000 -p=8000:8000 $(DOCKER_IMAGE_TAG) yarn gulp serve

build: yarn-install
	$(DOCKER_RUN) $(DOCKER_IMAGE_TAG) yarn gulp create-dist

deploy: yarn-install
	$(DOCKER_RUN) -e PORT -e HOSTNAME -v "$${SSH_AUTH_SOCK}":/ssh-auth.sock:ro -e SSH_AUTH_SOCK=/ssh-auth.sock $(DOCKER_IMAGE_TAG) yarn gulp deploy