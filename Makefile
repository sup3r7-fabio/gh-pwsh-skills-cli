# PowerShell GitHub Skills CLI Extension Makefile

.PHONY: help build test clean install uninstall release bump-major bump-minor bump-patch

# Go parameters - using snap Go installation
GOCMD=/snap/bin/go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod

# Binary name
BINARY_NAME=gh-pwsh-skills
BINARY_UNIX=$(BINARY_NAME)_unix

# Version info
VERSION ?= $(shell git describe --tags --always --dirty)
COMMIT ?= $(shell git rev-parse HEAD)
DATE ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILT_BY ?= $(shell whoami)

# Build flags
LDFLAGS=-ldflags "-s -w -X main.version=$(VERSION) -X main.commit=$(COMMIT) -X main.date=$(DATE) -X main.builtBy=$(BUILT_BY)"

## help: Show this help message
help:
	@echo "PowerShell GitHub Skills CLI Extension"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  %-15s %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

## build: Build the binary
build:
	$(GOBUILD) $(LDFLAGS) -o $(BINARY_NAME) -v ./...

## build-all: Build for all platforms
build-all:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_NAME)-linux-amd64 ./...
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_NAME)-linux-arm64 ./...
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_NAME)-darwin-amd64 ./...
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_NAME)-darwin-arm64 ./...
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BINARY_NAME)-windows-amd64.exe ./...

## test: Run tests
test:
	$(GOTEST) -v ./...

## test-coverage: Run tests with coverage
test-coverage:
	$(GOTEST) -race -coverprofile=coverage.out -covermode=atomic ./...
	$(GOCMD) tool cover -html=coverage.out -o coverage.html

## clean: Clean build files
clean:
	$(GOCLEAN)
	rm -f $(BINARY_NAME)
	rm -f $(BINARY_NAME)-*
	rm -f coverage.out coverage.html

## deps: Download dependencies
deps:
	$(GOMOD) download
	$(GOMOD) tidy
	$(GOMOD) verify

## install: Install the extension using gh CLI
install: build
	gh extension install .

## uninstall: Uninstall the extension
uninstall:
	gh extension remove sup3r7-fabio/gh-pwsh-skills || true

## lint: Run linter
lint:
	golangci-lint run

## format: Format code
format:
	$(GOCMD) fmt ./...

## vet: Run go vet
vet:
	$(GOCMD) vet ./...

## release: Create a release (requires VERSION)
release:
ifndef VERSION
	$(error VERSION is required. Usage: make release VERSION=v1.0.0)
endif
	./scripts/bump-version.sh -p $(VERSION)

## bump-major: Bump major version and create release
bump-major:
	./scripts/bump-version.sh -p major

## bump-minor: Bump minor version and create release
bump-minor:
	./scripts/bump-version.sh -p minor

## bump-patch: Bump patch version and create release
bump-patch:
	./scripts/bump-version.sh -p patch

## dev-setup: Setup development environment
dev-setup:
	$(GOGET) -u honnef.co/go/tools/cmd/staticcheck
	$(GOGET) -u github.com/golangci/golangci-lint/cmd/golangci-lint

## version: Show current version
version:
	@echo "Current version: $$(git describe --tags --always --dirty 2>/dev/null || echo 'v0.0.0')"
	@echo "Latest commit: $$(git rev-parse HEAD 2>/dev/null || echo 'unknown')"

## docker-build: Build using Docker
docker-build:
	docker run --rm -v "$$PWD":/usr/src/app -w /usr/src/app golang:1.21 make build

.DEFAULT_GOAL := help
