# Makefile

GOBIN := $(shell go env GOPATH)/bin

GOOGLEAPIS_REPO_URL = https://github.com/googleapis/googleapis.git
GOOGLEAPIS_TARGET_DIR = third_party/googleapis
GOOGLEAPIS_COMMIT = $(shell cat .googleapis.commit)

.PHONY: all deps progs fetch-googleapis common_types

all: protos

protos: \
	go.mod \
	fetch-googleapis \
	proto-auth \
	proto-health \
	proto-mail \
	proto-region \
	proto-router \
	proto-search
	go mod tidy

common_types:
	PATH="$(GOBIN):$(PATH)" \
	protoc -I . -I third_party/googleapis \
		-I /usr/local/include \
		--go_out=paths=source_relative:. \
		common_types/geo/geo.proto

proto-%: common_types
	PATH="$(GOBIN):$(PATH)" \
	protoc -I . -I third_party/googleapis \
		-I /usr/local/include \
		--go_out=paths=source_relative:. \
		--go-grpc_out=paths=source_relative:. \
		--grpc-gateway_out=paths=source_relative:. \
		$*/v1/$*.proto

go.mod:
	go mod init github.com/swayrider/protos

fetch-googleapis:
	@if [ ! -d "$(GOOGLEAPIS_TARGET_DIR)" ]; then \
		git clone "$(GOOGLEAPIS_REPO_URL)" "$(GOOGLEAPIS_TARGET_DIR)"; \
	fi
	@cd "$(GOOGLEAPIS_TARGET_DIR)" && \
		CURRENT=$$(git rev-parse HEAD) && \
		if [ "$(GOOGLEAPIS_COMMIT)" != "$$CURRENT" ]; then \
			git fetch origin; \
			git checkout "$(GOOGLEAPIS_COMMIT)"; \
		fi
