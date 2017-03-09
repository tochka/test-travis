
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
build/windows-amd64.zip:
	GOOS=windows GOARCH=amd64 go build  --ldflags '-extldflags "-static"' -o build/windows-amd64/$(ARTF)/$(ARTF).exe
	cd build/windows-amd64 &&	zip -r ../windows-amd64.zip . &&	cd ../..
	
build/macosx-amd64.tar.gz:
	GOOS=darwin GOARCH=amd64 go build -o build/macosx-amd64/$(ARTF)/$(ARTF)
	tar -zcvf build/macosx-amd64.tar.gz -C build/macosx-amd64/ .
	
build/linux-amd64.tar.gz:
	GOOS=linux GOARCH=amd64 go build -o build/linux-amd64/$(ARTF)/$(ARTF)
	tar -zcvf build/linux-amd64.tar.gz -C build/linux-amd64/ .
	
build_artifacts: clear build/windows-amd64.zip build/macosx-amd64.tar.gz build/linux-amd64.tar.gz

build_docker:
	docker build -t $(IMAGENAME) --build-arg GIT_COMMIT=$(GIT_COMMIT) --build-arg GIT_BRANCH=$(GIT_BRANCH) .

docker_dockerhub_publish:
	$(call tag_docker, $(DOCKERHUB_REPOSITORY))
	docker push $(DOCKERHUB_REPOSITORY)
