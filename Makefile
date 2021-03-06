
ARTF =test
IMAGENAME=$(ARTF)
DOCKERHUB_REPOSITORY=tochka/$(IMAGENAME)
VERSION=$(shell git describe --tags --always)

ifeq ($(OS),Windows_NT)
TARGET_OS ?= windows
else
TARGET_OS ?= $(shell uname -s | tr A-Z a-z)
endif

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

$(GOPATH)/src/gopkg.in/virgilsecurity/virgil-crypto-go.v4/virgil_crypto_go.go:
	go get -d gopkg.in/virgilsecurity/virgil-crypto-go.v4
	cd $$GOPATH/src/gopkg.in/virgilsecurity/virgil-crypto-go.v4 ;	 make BRANCH=v2.1.2

get: $(GOPATH)/src/gopkg.in/virgilsecurity/virgil-crypto-go.v4/virgil_crypto_go.go
	go get -v -d -t  ./...

test_all:
	go test ./... -coverprofile=coverage.txt -covermode=atomic

clear_artifact:
	rm -rf artf
build_artifact: clear_artifact clear
	GOOS=$(TARGET_OS) GOARCH=amd64 go build  --ldflags '-X main.Version=$(VERSION) -extldflags "-static"' -o build/$(ARTF)/$(ARTF)
	mkdir artf
	@if [ "$(TARGET_OS)" = "windows" ]; then \
		mv build/$(ARTF)/$(ARTF) build/$(ARTF)/$(ARTF).exe; \
		cd build/ && zip -r windows-amd64.zip . && cd .. ; \
		mv build/windows-amd64.zip artf/ ; \
	fi 
	@if [ "$(TARGET_OS)" = "linux" ]; then \
		tar -zcvf artf/linux-amd64.tar.gz -C build/ . ;  \
	fi
	@if [ "$(TARGET_OS)" = "darwin" ]; then \
		tar -zcvf artf/macosx-amd64.tar.gz -C build/ . ;  \
	fi

build_docker: build_artifact
	docker build -t $(IMAGENAME) --build-arg GIT_COMMIT=$(GIT_COMMIT) --build-arg GIT_BRANCH=$(GIT_BRANCH) .

docker_dockerhub_publish:
	$(call tag_docker, $(DOCKERHUB_REPOSITORY))
	docker push $(DOCKERHUB_REPOSITORY)
