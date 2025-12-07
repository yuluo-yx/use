APP_NAME=use
OUTPUT_DIR=bin

build:
	go build -o $(OUTPUT_DIR)/$(APP_NAME) main.go

build-all: build-linux-amd64 build-linux-arm64 build-darwin-amd64 build-darwin-arm64

# Linux AMD64
build-linux-amd64:
	GOOS=linux GOARCH=amd64 go build -o $(OUTPUT_DIR)/$(APP_NAME)-linux-amd64 main.go

# Linux ARM64
build-linux-arm64:
	GOOS=linux GOARCH=arm64 go build -o $(OUTPUT_DIR)/$(APP_NAME)-linux-arm64 main.go

# macOS AMD64 (Intel)
build-darwin-amd64:
	GOOS=darwin GOARCH=amd64 go build -o $(OUTPUT_DIR)/$(APP_NAME)-darwin-amd64 main.go

# macOS ARM64 (Apple Silicon)
build-darwin-arm64:
	GOOS=darwin GOARCH=arm64 go build -o $(OUTPUT_DIR)/$(APP_NAME)-darwin-arm64 main.go

# 清理编译产物
clean:
	rm -rf $(OUTPUT_DIR)

run:
	go run main.go

prod-run:
	./$(OUTPUT_DIR)/$(APP_NAME)

prod: build prod-run

.PHONY: build build-all build-linux-amd64 build-linux-arm64 build-darwin-amd64 build-darwin-arm64 clean run prod-run prod
