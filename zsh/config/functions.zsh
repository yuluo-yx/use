############################
# Ghostty Tab Title
############################
if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
    ghostty_set_title() {
        local dir="${PWD/#$HOME/~}"
        printf '\033]2;%s\033\\' "$dir"
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd ghostty_set_title
    add-zsh-hook precmd ghostty_set_title
    add-zsh-hook preexec ghostty_set_title
    ghostty_set_title
fi

############################
# Yazi Directory Switcher
############################
function y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

############################
# Log Filter
############################
function logcat() {
    GREP_COLORS='mt=01;42' command grep -E 'ERROR|WARNING|INFO|DEBUG' --color=always "$1" | \
        GREP_COLORS='mt=01;46' command grep "$2" --color=always
}

############################
# Directory Creator
############################
function mkcd() {
    mkdir -p -- "$1" && builtin cd -- "$1"
}

############################
# Proxy Controller
############################
function proxy() {
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="http://127.0.0.1:7890"
    export all_proxy="socks5://127.0.0.1:7898"
    echo "proxy on"
}

function noproxy() {
    unset http_proxy https_proxy all_proxy
    echo "proxy off"
}


############################
# Kueue Integration Tests
############################
function kueue-it() {
    local focus=""
    local verbose=""
    local target="./test/integration/singlecluster/controller/jobs/pod"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --target)
                target="$2"
                shift 2
                ;;
            --target=*)
                target="${1#--target=}"
                shift
                ;;
            --focus)
                focus="$2"
                shift 2
                ;;
            --focus=*)
                focus="${1#--focus=}"
                shift
                ;;
            -v|--verbose)
                verbose="-v"
                shift
                ;;
            *)
                if [[ -z "$focus" ]]; then
                    focus="$1"
                else
                    echo "unknown argument: $1" >&2
                    return 2
                fi
                shift
                ;;
        esac
    done

    local repo="/Users/shown/workspace/golang/kueue"
    local ginkgo_args=()
    [[ -n "$focus" ]] && ginkgo_args+=(--focus="$focus")
    [[ -n "$verbose" ]] && ginkgo_args+=("$verbose")

    KUBEBUILDER_ASSETS="/Users/shown/Library/Application Support/io.kubebuilder.envtest/k8s/1.37.0-darwin-arm64" \
    PROJECT_DIR="$repo/" \
    KUEUE_BIN="$repo/bin" \
    ENVTEST_K8S_VERSION=1.37 \
    ARTIFACTS="$repo/artifacts" \
    TEST_LOG_LEVEL=-3 \
    API_LOG_LEVEL=0 \
    GORACE="log_path=$repo/artifacts/race" \
    GOTRACEBACK=system \
    "$repo/bin/ginkgo" \
        "${ginkgo_args[@]}" \
        -procs=1 \
        --race \
        "$target"
}

############################
# Kueue Local Checks
############################
function _kueue-env() {
    local repo="/Users/shown/workspace/golang/kueue"

    export PROJECT_DIR="$repo/"
    export BIN_DIR="$repo/bin"
    export KUEUE_BIN="$repo/bin"
    export ARTIFACTS="$repo/artifacts"
    export ENVTEST_K8S_VERSION="${ENVTEST_K8S_VERSION:-1.37}"
    export KUBEBUILDER_ASSETS="${KUBEBUILDER_ASSETS:-/Users/shown/Library/Application Support/io.kubebuilder.envtest/k8s/1.37.0-darwin-arm64}"
    export TEST_LOG_LEVEL="${TEST_LOG_LEVEL:--3}"
    export API_LOG_LEVEL="${API_LOG_LEVEL:-0}"
    export GOTRACEBACK="${GOTRACEBACK:-system}"
    export GORACE="${GORACE:-log_path=$repo/artifacts/race}"

    path=("$repo/bin" $path)
}

function _kueue-ci-lint-cached() {
    local repo="/Users/shown/workspace/golang/kueue"
    local lint="$repo/bin/golangci-lint"
    local nprocs="${KUEUE_CI_LINT_NPROCS:-4}"

    if [[ ! -x "$lint" ]]; then
        echo "golangci-lint not found in $repo/bin; installing once with make golangci-lint"
        make golangci-lint || return
    fi

    find . \( -path ./site -o -path ./bin -o -path ./vendor \) -prune -false -o -name go.mod -exec dirname {} \; | \
        xargs -P "$nprocs" -n 1 sh -c '
            cd "$3" || exit 1
            dirs=$(go list -f "{{.Dir}}" ./... | grep -vE "/(client-go|internal/mocks)(/|$)" | sed "s|^$(pwd)/|./|")
            [ -n "$dirs" ] || exit 0
            "$1" run \
                --allow-parallel-runners \
                --timeout 15m0s \
                --config "$2/.golangci.yaml" \
                $dirs
        ' sh "$lint" "$repo"
}

function kueue-check() {
    local run_unit=""
    local unit_target="./pkg/controller/jobs/pod"
    local unit_run=""
    local run_integration=""
    local integration_focus=""
    local integration_target="./test/integration/singlecluster/controller/jobs/pod"
    local refresh_tools=""
    local run_verify=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --unit)
                run_unit="1"
                shift
                ;;
            --unit-target)
                unit_target="$2"
                shift 2
                ;;
            --unit-target=*)
                unit_target="${1#--unit-target=}"
                shift
                ;;
            --unit-run)
                unit_run="$2"
                shift 2
                ;;
            --unit-run=*)
                unit_run="${1#--unit-run=}"
                shift
                ;;
            --integration)
                run_integration="1"
                shift
                ;;
            --integration-focus)
                integration_focus="$2"
                shift 2
                ;;
            --integration-focus=*)
                integration_focus="${1#--integration-focus=}"
                shift
                ;;
            --integration-target)
                integration_target="$2"
                shift 2
                ;;
            --integration-target=*)
                integration_target="${1#--integration-target=}"
                shift
                ;;
            --refresh-tools)
                refresh_tools="1"
                shift
                ;;
            --verify)
                run_verify="1"
                shift
                ;;
            -h|--help)
                cat <<'EOF'
usage: kueue-check [options]

Runs local Kueue checks with the repo's cached bin/ tools and envtest assets.

Default:
  make fmt
  cached golangci-lint run
  make fmt-verify
  make gomod-verify

Options:
  --unit                              run focused unit tests after checks
  --unit-target <pkg>                 unit test target (default: ./pkg/controller/jobs/pod)
  --unit-run <regex>                  pass -run to go test
  --integration                       run focused integration tests after checks
  --integration-focus <regex>         pass --focus to kueue-it
  --integration-target <pkg>          integration target package
  --refresh-tools                     reinstall golangci-lint before linting
  --verify                            run make verify after the quick checks
EOF
                return 0
                ;;
            *)
                echo "unknown argument: $1" >&2
                return 2
                ;;
        esac
    done

    local repo="/Users/shown/workspace/golang/kueue"
    builtin cd "$repo" || return
    _kueue-env

    if [[ -n "$refresh_tools" ]]; then
        make golangci-lint || return
    fi

    make fmt || return
    _kueue-ci-lint-cached || return
    make fmt-verify || return
    make gomod-verify || return

    if [[ -n "$run_verify" ]]; then
        make verify || return
    fi

    if [[ -n "$run_unit" ]]; then
        if [[ -n "$unit_run" ]]; then
            go test "$unit_target" -run "$unit_run" || return
        else
            go test "$unit_target" || return
        fi
    fi

    if [[ -n "$run_integration" ]]; then
        if [[ -n "$integration_focus" ]]; then
            kueue-it --target "$integration_target" --focus "$integration_focus" || return
        else
            kueue-it --target "$integration_target" || return
        fi
    fi
}

