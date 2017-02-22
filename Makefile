
ARTF = test
IMAGENAME=$(ARTF)
DOCKERHUB_REPOSITORY=tochka/$(IMAGENAME)


define tag_docker
	@echo "git commit: $(GIT_BRANCH)"
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
	GOOS=linux GOARCH=amd64 go build -o build/linux_x64/test
	GOOS=linux GOARCH=386 go build -o build/linux_x86/test
	GOOS=windows GOARCH=amd64 go build -o build/windws_x64/test.exe
	GOOS=windows GOARCH=386 go build -o build/windows_x86/test.exe

build_docker:
	docker build -t $(IMAGENAME) --build-arg GIT_COMMIT=$(GIT_COMMIT) --build-arg GIT_BRANCH=$(GIT_BRANCH) .

docker_dockerhub_tag:
	$(call tag_docker, $(DOCKERHUB_REPOSITORY))

docker_dockerhub_push:
	docker push $(DOCKERHUB_REPOSITORY)
