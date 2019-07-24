export DOCKER_REPO := stefco/llama-env
export DOCKERFILE_PATH := Dockerfile

.PHONY: help
help:
	@echo "Please use \`make <target>\` where <target> is one of:"
	@echo "  help           show this message"
	@echo "  36             Docker Cloud-style llama-env:py36 image build"
	@echo "  37             Docker Cloud-style llama-env:py37 image build"
	@echo "  push36         docker push llama-env:py36"
	@echo "  push37         docker push llama-env:py37"

.PHONY: 36
36:
	$(eval export DOCKER_TAG := py36)
	hooks/build --squash

.PHONY: 37
37:
	$(eval export DOCKER_TAG := py37)
	hooks/build --squash

.PHONY: push36
push36:
	$(eval export DOCKER_TAG := py36)
	docker push $$DOCKER_REPO:$$DOCKER_TAG
	hooks/post_push

.PHONY: push37
push37:
	$(eval export DOCKER_TAG := py37)
	docker push $$DOCKER_REPO:$$DOCKER_TAG
	hooks/post_push
