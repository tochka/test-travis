
ARTF =test
IMAGENAME=$(ARTF)
DOCKERHUB_REPOSITORY=tochka/$(IMAGENAME)
TARGET_OS ?= $(shell uname -s)

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

get:
	go get -v -d -t  ./...

test_all:
	go test ./...
	
build_artifact:
	GOOS=$(TARGET_OS) GOARCH=amd64 go build  --ldflags '-extldflags "-static"' -o build/$(ARTF)/$(ARTF)
	@if [ "$(TARGET_OS)" = "windows" ]; then \
		echo "WINDOWS"; \
		mv build/$(ARTF)/$(ARTF) build/$(ARTF)/$(ARTF).exe; \
		cd build/ && zip -r windows-amd64.zip . && cd ..; \
	else \
		HUMAN_NAME=["$(TARGET_OS)" = "darwin" && "macos" || "linux"; \
		echo "NOT WINDOWS $(HUMAN_NAME)"; \		
		tar -zcvf build/$(HUMAN_NAME)-amd64.tar.gz -C build/ .; \
	fi
build_docker: build_artifact
	docker build -t $(IMAGENAME) --build-arg GIT_COMMIT=$(GIT_COMMIT) --build-arg GIT_BRANCH=$(GIT_BRANCH) .

docker_dockerhub_publish:
	$(call tag_docker, $(DOCKERHUB_REPOSITORY))
	docker push $(DOCKERHUB_REPOSITORY)
