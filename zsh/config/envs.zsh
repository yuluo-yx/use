# AI envs
export AI_DASHSCOPE_API_KEY="sk-xxxx"
export AI_OPENAI_API_KEY="sk-xxxx"

# fultter
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# daytona sandbox
# https://app.daytona.io/dashboard/onboarding
export DAYTONA_API_KEY="xxxx"

# Rust
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
export CARGO_UNSTABLE_SPARSE_REGISTRY=true
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Go
export GO111MODULE=on
export GOPROXY=https://goproxy.cn,direct
