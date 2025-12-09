APP_NAME=use
OUTPUT_DIR=bin
# 版本信息（从 git tag 获取，如果没有则使用 dev）
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
# 构建时间
BUILD_TIME=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
# Git commit
GIT_COMMIT=$(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
# LDFLAGS 用于优化二进制大小和嵌入版本信息
LDFLAGS=-s -w \
	-X 'main.Version=$(VERSION)' \
	-X 'main.BuildTime=$(BUILD_TIME)' \
	-X 'main.GitCommit=$(GIT_COMMIT)'

build:
	go build -ldflags "$(LDFLAGS)" -o $(OUTPUT_DIR)/$(APP_NAME) main.go

build-all: clean build-linux-amd64 build-linux-arm64 build-darwin-amd64 build-darwin-arm64
	@echo "所有平台构建完成！"
	@ls -lh $(OUTPUT_DIR)

# Linux AMD64
build-linux-amd64:
	@echo "构建 Linux AMD64..."
	@GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o $(OUTPUT_DIR)/$(APP_NAME)-linux-amd64 main.go

# Linux ARM64
build-linux-arm64:
	@echo "构建 Linux ARM64..."
	@GOOS=linux GOARCH=arm64 go build -ldflags "$(LDFLAGS)" -o $(OUTPUT_DIR)/$(APP_NAME)-linux-arm64 main.go

# macOS AMD64 (Intel)
build-darwin-amd64:
	@echo "构建 macOS AMD64..."
	@GOOS=darwin GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o $(OUTPUT_DIR)/$(APP_NAME)-darwin-amd64 main.go

# macOS ARM64 (Apple Silicon)
build-darwin-arm64:
	@echo "构建 macOS ARM64..."
	@GOOS=darwin GOARCH=arm64 go build -ldflags "$(LDFLAGS)" -o $(OUTPUT_DIR)/$(APP_NAME)-darwin-arm64 main.go

# 生成校验和
checksums:
	@echo "生成校验和..."
	@cd $(OUTPUT_DIR) && sha256sum $(APP_NAME)-* > checksums.txt
	@echo "校验和文件已生成："
	@cat $(OUTPUT_DIR)/checksums.txt

# 发布构建（清理 + 构建所有平台 + 生成校验和）
release: build-all checksums
	@echo "Release 构建完成！"

# 清理编译产物
clean:
	@echo "清理编译产物..."
	@rm -rf $(OUTPUT_DIR)

run:
	go run main.go

prod-run:
	./$(OUTPUT_DIR)/$(APP_NAME)

prod: build prod-run

# 显示版本信息
version:
	@echo "Version:    $(VERSION)"
	@echo "Build Time: $(BUILD_TIME)"
	@echo "Git Commit: $(GIT_COMMIT)"

# 帮助信息
help:
	@echo "可用命令："
	@echo "  make build              - 构建当前平台"
	@echo "  make build-all          - 构建所有平台"
	@echo "  make build-linux-amd64  - 构建 Linux AMD64"
	@echo "  make build-linux-arm64  - 构建 Linux ARM64"
	@echo "  make build-darwin-amd64 - 构建 macOS Intel"
	@echo "  make build-darwin-arm64 - 构建 macOS Apple Silicon"
	@echo "  make release            - 发布构建（所有平台+校验和）"
	@echo "  make checksums          - 生成校验和文件"
	@echo "  make clean              - 清理编译产物"
	@echo "  make run                - 运行（开发模式）"
	@echo "  make prod               - 构建并运行"
	@echo "  make version            - 显示版本信息"
	@echo "  make help               - 显示此帮助信息"

.PHONY: build build-all build-linux-amd64 build-linux-arm64 build-darwin-amd64 build-darwin-arm64 \
	checksums release clean run prod-run prod version help
