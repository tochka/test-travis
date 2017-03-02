
ARTF =test
IMAGENAME=$(ARTF)
DOCKERHUB_REPOSITORY=tochka/$(IMAGENAME)
OS = $(shell uname -s) 

define tag_docker
	@if [ "$(GIT_BRANCH)" = "master" ]; then \
		docker tag $(IMAGENAME) $(1):latest; \
	fi
	@if [ "$(GIT_BRANCH)" != "master" ]; then \
		docker tag $(IMAGENAME) $(1):$(GIT_BRANCH); \
	fi
 endef

clear:
	rm -rf build
build_artifacts: clear
	GOOS=$(OS) go build -o /build/travis-test/test
	tar -zcvf $(OS)-amd64.tar.gz -C build/ .
	ls -l


build_docker:
	docker build -t $(IMAGENAME) --build-arg GIT_COMMIT=$(GIT_COMMIT) --build-arg GIT_BRANCH=$(GIT_BRANCH) .

docker_dockerhub_publish:
	$(call tag_docker, $(DOCKERHUB_REPOSITORY))
	docker push $(DOCKERHUB_REPOSITORY)
