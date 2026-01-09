package main

import (
	"bytes"
	"embed"
	"errors"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"text/template"
)

type action string

type osType string

type archType string

type ExecFunc func() error

type tools string

const (
	ToolGit tools = "git"
	ToolVim tools = "vim"
	ToolZsh tools = "zsh"
	ToolOMZ tools = "oh-my-zsh"

	// https://github.com/nvbn/thefuck
	ToolTheFuck tools = "thefuck"
	// https://github.com/eza-community/eza
	ToolEza tools = "eza"
	// https://github.com/junegunn/fzf
	ToolFzf tools = "fzf"
	// https://github.com/sharkdp/bat
	ToolBat tools = "bat"
	// https://github.com/moovweb/gvm
	ToolGvm tools = "gvm"
	// https://sdkman.io/
	ToolSdkman tools = "sdkman"
	// https://rustup.rs/
	ToolRustup tools = "rustup"

	OSLinux  osType = "linux"
	OSDarwin osType = "darwin"

	// not supported yet
	OSWindows osType = "windows"

	ArchAMD64 archType = "amd64"
	ArchARM64 archType = "arm64"

	ActionCheck   action = "check"
	ActionInstall action = "install"
	ActionConfig  action = "config"
)

var (
	//go:embed git/.gitconfig
	gitConfig embed.FS

	//go:embed vim/.vimrc vim/simple._vimrc
	vimConfig embed.FS

	//go:embed zsh/.zshrc zsh/config/* zsh/theme/*
	zshConfig embed.FS

	configVim   *bool
	configGit   *bool
	configZsh   *bool
	configMacos *bool
	configAll   *bool
	configGvm   *bool
	configJava  *bool
	configRust  *bool
	dryRun      *bool
	force       *bool
	gitName     *string
	gitEmail    *string

	ErrPkgManager    = errors.New("无法检测到可用的包管理器")
	ErrUnsupportedOS = errors.New("不支持的操作系统")
	ErrUnknownTool   = errors.New("未知工具")

	toolErrors = map[tools]map[action]error{
		ToolGit:     {ActionCheck: errors.New("检查 git 安装失败"), ActionInstall: errors.New("安装 git 失败"), ActionConfig: errors.New("git 配置失败")},
		ToolVim:     {ActionCheck: errors.New("检查 vim 安装失败"), ActionInstall: errors.New("安装 vim 失败"), ActionConfig: errors.New("vim 配置失败")},
		ToolZsh:     {ActionCheck: errors.New("检查 zsh 安装失败"), ActionInstall: errors.New("安装 zsh 失败"), ActionConfig: errors.New("zsh 配置失败")},
		ToolOMZ:     {ActionCheck: errors.New("检查 oh-my-zsh 安装失败"), ActionInstall: errors.New("安装 oh-my-zsh 失败")},
		ToolTheFuck: {ActionCheck: errors.New("检查 thefuck 安装失败"), ActionInstall: errors.New("安装 thefuck 失败")},
		ToolEza:     {ActionCheck: errors.New("检查 eza 安装失败"), ActionInstall: errors.New("安装 eza 失败")},
		ToolFzf:     {ActionCheck: errors.New("检查 fzf 安装失败"), ActionInstall: errors.New("安装 fzf 失败")},
		ToolBat:     {ActionCheck: errors.New("检查 bat 安装失败"), ActionInstall: errors.New("安装 bat 失败")},
		ToolGvm:     {ActionCheck: errors.New("检查 gvm 安装失败"), ActionInstall: errors.New("安装 gvm 失败")},
		ToolSdkman:  {ActionCheck: errors.New("检查 sdkman 安装失败"), ActionInstall: errors.New("安装 sdkman 失败")},
		ToolRustup:  {ActionCheck: errors.New("检查 rustup 安装失败"), ActionInstall: errors.New("安装 rustup 失败")},
	}
)

func init() {
	configVim = flag.Bool("vim", false, "配置 vim")
	configGit = flag.Bool("git", false, "配置 git")
	configZsh = flag.Bool("zsh", false, "配置 zsh")
	configMacos = flag.Bool("macos", false, "macOS 个性化配置")
	configAll = flag.Bool("all", false, "配置所有工具")
	configGvm = flag.Bool("gvm", false, "安装并配置 GVM (Go Version Manager)")
	configJava = flag.Bool("java", false, "安装并配置 SDKMAN (Java Version Manager)")
	configRust = flag.Bool("rust", false, "安装并配置 Rustup (Rust Version Manager)")
	dryRun = flag.Bool("dry-run", false, "预览模式，不实际执行操作")
	force = flag.Bool("f", false, "强制覆盖已存在的文件")
	gitName = flag.String("git-name", "", "Git 用户名")
	gitEmail = flag.String("git-email", "", "Git 邮箱")
}

func main() {
	flag.Parse()

	if err := _main(); err != nil {
		panic(err)
	}
}

func getError(tool tools, act action) error {

	if errs, ok := toolErrors[tool]; ok {
		if err, ok := errs[act]; ok {
			return err
		}
	}

	return ErrUnknownTool
}

func conditionOS() (osType, error) {

	switch runtime.GOOS {
	case "linux":
		return OSLinux, nil
	case "darwin":
		return OSDarwin, nil
	default:
		return "", ErrUnsupportedOS
	}
}

func getArch() archType {

	switch runtime.GOARCH {
	case "amd64":
		return ArchAMD64
	case "arm64":
		return ArchARM64
	default:
		return ArchARM64
	}
}

func execCmd(cmd string, args ...string) error {

	if *dryRun {
		slog.Info("[DRY RUN] 执行命令", "cmd", cmd, "args", args)
		return nil
	}

	output, err := exec.Command(cmd, args...).CombinedOutput()
	if err != nil && len(output) > 0 {
		return fmt.Errorf("%w: %s", err, string(output))
	}
	return err
}

// getRealUser 获取实际用户的 UID 和 GID，即使在 sudo 下运行
// 返回值: uid, gid, error
func getRealUser() (int, int, error) {
	// 如果不是 root，直接返回当前用户
	if os.Getuid() != 0 {
		return os.Getuid(), os.Getgid(), nil
	}

	// 如果是 root，尝试获取 SUDO_USER
	sudoUser := os.Getenv("SUDO_USER")
	if sudoUser == "" {
		// 没有 SUDO_USER，可能是真的 root
		return 0, 0, nil
	}

	// 获取 SUDO_USER 的用户信息
	u, err := user.Lookup(sudoUser)
	if err != nil {
		return 0, 0, fmt.Errorf("查找用户 %s 失败: %w", sudoUser, err)
	}

	uid, err := strconv.Atoi(u.Uid)
	if err != nil {
		return 0, 0, fmt.Errorf("解析 UID 失败: %w", err)
	}

	gid, err := strconv.Atoi(u.Gid)
	if err != nil {
		return 0, 0, fmt.Errorf("解析 GID 失败: %w", err)
	}

	return uid, gid, nil
}

// chownIfNeeded 如果当前是 root 用户运行，则修改文件所有权为实际用户
func chownIfNeeded(path string) error {
	if os.Getuid() != 0 {
		return nil
	}

	uid, gid, err := getRealUser()
	if err != nil {
		return err
	}

	// 如果是真正的 root 用户（不是 sudo），不需要修改权限
	if uid == 0 {
		return nil
	}

	return os.Chown(path, uid, gid)
}

func writeFile(path string, data []byte, perm os.FileMode) error {

	if *dryRun {
		slog.Info("[DRY RUN] 写入文件", "path", path, "size", len(data))
		return nil
	}

	if err := os.WriteFile(path, data, perm); err != nil {
		return err
	}

	return chownIfNeeded(path)
}

func mkdirAll(path string, perm os.FileMode) error {

	if *dryRun {
		slog.Info("[DRY RUN] 创建目录", "path", path)
		return nil
	}

	if err := os.MkdirAll(path, perm); err != nil {
		return err
	}

	return chownIfNeeded(path)
}

// downloadAndInstallBinary 下载并安装二进制文件
// 兼容 fzf 包管理器版本过低等其他问题
func downloadAndInstallBinary(url, tmpFile, binName, targetDir string) error {

	if *dryRun {
		slog.Info("[DRY RUN] 下载并安装二进制", "url", url, "target", filepath.Join(targetDir, binName))
		return nil
	}

	slog.Info("正在下载", "url", url)
	if err := execCmd("curl", "-fsSL", "-o", tmpFile, url); err != nil {
		return fmt.Errorf("下载失败: %w", err)
	}

	if err := mkdirAll(targetDir, 0755); err != nil {
		return fmt.Errorf("创建目录失败: %w", err)
	}

	slog.Info("正在解压", "file", tmpFile)
	tmpDir := filepath.Join("/tmp", "extract_"+binName)
	if err := mkdirAll(tmpDir, 0755); err != nil {
		return fmt.Errorf("创建临时目录失败: %w", err)
	}
	defer os.RemoveAll(tmpDir)

	// 根据文件类型解压
	if strings.HasSuffix(tmpFile, ".tar.gz") || strings.HasSuffix(tmpFile, ".tgz") {
		if err := execCmd("tar", "-xzf", tmpFile, "-C", tmpDir); err != nil {
			return fmt.Errorf("解压失败: %w", err)
		}
	} else if strings.HasSuffix(tmpFile, ".zip") {
		if err := execCmd("unzip", "-q", tmpFile, "-d", tmpDir); err != nil {
			return fmt.Errorf("解压失败: %w", err)
		}
	}

	var foundBinary string
	filepath.Walk(tmpDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && (info.Name() == binName || strings.HasPrefix(info.Name(), binName)) {
			if info.Mode()&0111 != 0 {
				foundBinary = path
				return filepath.SkipDir
			}
		}
		return nil
	})

	if foundBinary == "" {
		return fmt.Errorf("未找到二进制文件: %s", binName)
	}

	targetPath := filepath.Join(targetDir, binName)
	if err := execCmd("mv", foundBinary, targetPath); err != nil {
		return fmt.Errorf("移动文件失败: %w", err)
	}

	if err := execCmd("chmod", "+x", targetPath); err != nil {
		return fmt.Errorf("设置权限失败: %w", err)
	}

	if _, err := os.Stat(tmpFile); err == nil {
		os.Remove(tmpFile)
	}

	slog.Info("安装成功", "binary", binName, "path", filepath.Join(targetDir, binName))
	return nil
}

// installBinaryTool 安装二进制工具（fzf, bat, eza）
func installBinaryTool(tool tools) error {

	const (
		fzfVersion    = "0.67.0"
		fzfGithubLink = "https://github.com/junegunn/fzf/releases/download/v%s/fzf-%s-%s_%s.tar.gz"

		batVersion    = "0.26.1"
		batGithubLink = "https://github.com/sharkdp/bat/releases/download/v%s/bat-v%s-%s.tar.gz"

		ezaVersion    = "0.23.4"
		ezaGithubLink = "https://github.com/eza-community/eza/releases/download/v%s/eza_%s.tar.gz"
	)

	var (
		err                                        error
		homeDir, homeBinDir, url, tmpFile, binName string
		arch                                       = getArch()
		systemBinDir                               = "/usr/local/bin"
		tmpDir                                     = "/tmp"
	)

	homeDir, err = os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("获取用户目录失败: %w", err)
	}
	osStr, err := conditionOS()
	if err != nil {
		return err
	}

	// 对于二进制文件路径，优先使用系统 bin 路径，其次用用户 bin 路径
	homeBinDir = fmt.Sprintf("%s/.local/bin", homeDir)
	targetDir := systemBinDir
	if _, err := os.Stat(systemBinDir); os.IsNotExist(err) {
		if err := mkdirAll(systemBinDir, 0755); err != nil {
			targetDir = homeBinDir
		}
	}

	switch tool {
	case ToolFzf:
		binName = string(tool)
		url = fmt.Sprintf(fzfGithubLink, fzfVersion, fzfVersion, osStr, arch)
		tmpFile = tmpDir + "/fzf.tar.gz"
	case ToolBat:
		binName = string(tool)
		var platform string
		switch osStr {
		case OSLinux:
			if arch == ArchARM64 {
				platform = "aarch64-unknown-linux-gnu"
			} else {
				platform = "x86_64-unknown-linux-gnu"
			}
		case OSDarwin:
			if arch == ArchARM64 {
				platform = "aarch64-apple-darwin"
			} else {
				platform = "x86_64-apple-darwin"
			}
		}
		url = fmt.Sprintf(batGithubLink, batVersion, batVersion, platform)
		tmpFile = tmpDir + "/bat.tar.gz"
	case ToolEza:
		binName = string(tool)
		switch osStr {
		case OSLinux:
			var platform string
			if arch == ArchARM64 {
				platform = "aarch64-unknown-linux-gnu"
			} else {
				platform = "x86_64-unknown-linux-gnu"
			}
			url = fmt.Sprintf(ezaGithubLink, ezaVersion, platform)
		case OSDarwin:
			// eza 在 macOS 上没有预编译二进制，用包管理器
			pm, args, err := getPackageManager()
			if err != nil {
				return fmt.Errorf("获取包管理器失败: %w", err)
			}

			cmd := pm
			cmdArgs := append(args, "eza")

			// 如果是 root 用户且使用 brew，降级到 SUDO_USER
			// homebrew 在 root 下会报错
			if os.Getuid() == 0 && pm == "brew" {
				if sudoUser := os.Getenv("SUDO_USER"); sudoUser != "" {
					cmd = "sudo"
					cmdArgs = append([]string{"-u", sudoUser, pm}, cmdArgs...)
				} else {
					slog.Warn("警告: 正在以 root 身份运行 Homebrew，可能会失败")
				}
			}

			if err := execCmd(cmd, cmdArgs...); err != nil {
				return fmt.Errorf("安装 eza 失败: %w", err)
			}
			slog.Info("已安装", "tool", "eza")
			return nil
		}
		tmpFile = tmpDir + "/eza.tar.gz"
	default:
		return fmt.Errorf("不支持的工具: %s", tool)
	}

	if url == "" {
		return fmt.Errorf("无法确定下载链接")
	}

	return downloadAndInstallBinary(url, tmpFile, binName, targetDir)
}

func getPackageManager() (string, []string, error) {

	osStr, err := conditionOS()
	if err != nil {
		return "", nil, err
	}

	if osStr == OSDarwin {
		return "brew", []string{"install"}, nil
	}

	// Linux package managers
	managers := []struct {
		name string
		args []string
	}{
		{"apt", []string{"install", "-y"}},
		{"yum", []string{"install", "-y"}},
		{"dnf", []string{"install", "-y"}},
		{"pacman", []string{"-S", "--noconfirm"}},
	}

	for _, pm := range managers {
		if _, err := exec.LookPath(pm.name); err == nil {
			return pm.name, pm.args, nil
		}
	}

	return "", nil, ErrPkgManager
}

func checkFunc(cmdName tools, errMsg error) ExecFunc {

	return func() error {

		homeDir, err := os.UserHomeDir()
		if err != nil {
			return fmt.Errorf("%w: %w", errMsg, err)
		}

		if cmdName == ToolOMZ {
			omzPath := filepath.Join(homeDir, ".oh-my-zsh")
			if _, err := os.Stat(omzPath); os.IsNotExist(err) {
				return fmt.Errorf("%w: oh-my-zsh not found", errMsg)
			}
			return nil
		}

		if _, err := exec.LookPath(string(cmdName)); err != nil {
			return fmt.Errorf("%w: %w", errMsg, err)
		}
		return nil
	}
}

func installFunc(pkgName tools, errMsg error) ExecFunc {

	return func() error {

		// 通过 bash 脚本安装的工具
		// todo 挪到 downloadAndInstallBinary 函数中
		if pkgName == ToolOMZ {
			slog.Info("  → 使用脚本安装 Oh-My-Zsh", "url", "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh")
			installCmd := `RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
			if err := execCmd("bash", "-c", installCmd); err != nil {
				return fmt.Errorf("%w: %w", errMsg, err)
			}
			slog.Info("  ✓ 已安装", "tool", "oh-my-zsh")
			return nil
		}

		if pkgName == ToolGvm {
			slog.Info("  → 使用脚本安装 GVM", "url", "https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer")
			installCmd := `bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)`
			if err := execCmd("bash", "-c", installCmd); err != nil {
				slog.Warn("安装 gvm 失败，请尝试手动安装", "error", err)
				return nil
			}
			slog.Info("  ✓ 已安装", "tool", "gvm")
			return nil
		}

		if pkgName == ToolSdkman {
			slog.Info("  → 使用脚本安装 SDKMAN", "url", "https://get.sdkman.io")
			installCmd := `curl -s "https://get.sdkman.io" | bash`
			if err := execCmd("bash", "-c", installCmd); err != nil {
				slog.Warn("安装 sdkman 失败，请尝试手动安装", "error", err)
				return nil
			}
			slog.Info("  ✓ 已安装", "tool", "sdkman")
			return nil
		}

		if pkgName == ToolRustup {
			slog.Info("  → 使用脚本安装 Rustup", "url", "https://sh.rustup.rs")
			installCmd := `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y`
			if err := execCmd("bash", "-c", installCmd); err != nil {
				slog.Warn("安装 rustup 失败，请尝试手动安装", "error", err)
				return nil
			}
			slog.Info("  ✓ 已安装", "tool", "rustup")
			return nil
		}

		// fzf, bat, eza 使用自定义的二进制安装方式安装
		if pkgName == ToolFzf || pkgName == ToolBat || pkgName == ToolEza {
			slog.Info("  → 使用二进制安装", "tool", string(pkgName))
			if err := installBinaryTool(pkgName); err != nil {
				return fmt.Errorf("%w: %w", errMsg, err)
			}
			return nil
		}

		pm, args, err := getPackageManager()
		if err != nil {
			return fmt.Errorf("获取包管理器失败: %w", err)
		}

		slog.Info("  → 使用包管理器安装", "package_manager", pm, "tool", string(pkgName))
		fullArgs := append(args, string(pkgName))
		if err := execCmd(pm, fullArgs...); err != nil {
			return fmt.Errorf("%w: %w", errMsg, err)
		}

		slog.Info("  ✓ 安装成功", "tool", string(pkgName))
		return nil
	}
}

func checkAndInstall(tool tools) error {

	slog.Info("  → 检查工具是否已安装", "tool", string(tool))
	if err := checkFunc(tool, getError(tool, ActionCheck))(); err != nil {
		slog.Info("  → 工具未安装，开始安装", "tool", string(tool))
		if err := installFunc(tool, getError(tool, ActionInstall))(); err != nil {
			return err
		}
		slog.Info("  ✓ 工具安装完成", "tool", string(tool))
		return nil
	}

	slog.Info("  ✓ 工具已存在", "tool", string(tool))
	return nil
}

func zsh() error {

	var (
		// 需要 git clone 安装的插件
		plugins = []struct {
			name string
			url  string
		}{
			{"zsh-autosuggestions", "https://github.com/zsh-users/zsh-autosuggestions"},
			{"zsh-syntax-highlighting", "https://github.com/zsh-users/zsh-syntax-highlighting.git"},
		}
	)

	slog.Info("===========================================")
	slog.Info("正在配置 zsh")
	slog.Info("===========================================")

	fmt.Println("\033[36mStep1: 配置文件\033[0m")
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("%w: %w", getError(ToolZsh, ActionConfig), err)
	}

	// 复制 .zshrc
	zshrcPath := filepath.Join(homeDir, ".zshrc")

	if _, err := os.Stat(zshrcPath); err == nil && !*force {
		slog.Info(".zshrc 已存在，跳过 (使用 -f 强制覆盖)", "path", zshrcPath)
	} else {
		// 备份旧文件（如果存在且使用强制覆盖）
		if _, err := os.Stat(zshrcPath); err == nil && *force {
			backupPath := zshrcPath + ".backup"
			if err := os.Rename(zshrcPath, backupPath); err != nil {
				slog.Info("备份旧配置失败", "error", err.Error())
			} else {
				slog.Info("已备份旧配置", "path", backupPath)
			}
		}

		input, err := zshConfig.ReadFile("zsh/.zshrc")
		if err != nil {
			return fmt.Errorf("%w: 读取嵌入 .zshrc 失败: %w", getError(ToolZsh, ActionConfig), err)
		}
		if err := writeFile(zshrcPath, input, 0644); err != nil {
			return fmt.Errorf("%w: 写入 .zshrc 失败: %w", getError(ToolZsh, ActionConfig), err)
		}
		slog.Info("已复制 .zshrc", "path", zshrcPath)
	}

	var customZshCfgDir string
	if os.Getuid() == 0 {
		customZshCfgDir = fmt.Sprintf(".%s_env/%s", os.Getenv("SUDO_USER"), ToolZsh)
	} else {
		customZshCfgDir = fmt.Sprintf(".%s_env/%s", os.Getenv("USER"), ToolZsh)
	}

	// 复制 config 目录
	configDir := filepath.Join(
		homeDir,
		customZshCfgDir,
	)
	if err := mkdirAll(configDir, 0755); err != nil {
		return fmt.Errorf("%w: 创建配置目录失败: %w", getError(ToolZsh, ActionConfig), err)
	}

	configFiles := []string{"aliases.zsh", "envs.zsh", "function.zsh", "fzf.zsh"}
	for _, file := range configFiles {
		src := filepath.Join("zsh/config", file)
		dst := filepath.Join(configDir, file)

		// 检查文件是否存在，如果存在且没有 force 标志则跳过
		if _, err := os.Stat(dst); err == nil && !*force {
			slog.Info("配置文件已存在，跳过", "file", file)
			continue
		}

		// 从 embed 配置文件读取
		data, err := zshConfig.ReadFile(src)
		if err != nil {
			slog.Info("跳过文件", "file", file, "reason", "读取失败")
			continue
		}

		if file == "envs.zsh" {
			tmpl, err := template.New("envs").Parse(string(data))
			if err != nil {
				return fmt.Errorf("%w: 解析 envs.zsh 模板失败: %w", getError(ToolZsh, ActionConfig), err)
			}
			var buf bytes.Buffer
			dataMap := map[string]interface{}{
				"Gvm":  *configAll || *configGvm,
				"Java": *configAll || *configJava,
				"Rust": *configAll || *configRust,
				"User": os.Getenv("USER"),
			}
			if err := tmpl.Execute(&buf, dataMap); err != nil {
				return fmt.Errorf("%w: 执行 envs.zsh 模板失败: %w", getError(ToolZsh, ActionConfig), err)
			}
			data = buf.Bytes()
		}

		if err := writeFile(dst, data, 0644); err != nil {
			return fmt.Errorf("%w: 写入配置文件 %s 失败: %w", getError(ToolZsh, ActionConfig), file, err)
		}
	}
	slog.Info("已复制 zsh 配置文件", "count", len(configFiles))

	fmt.Println("\033[36mStep2: 安装主题\033[0m")
	omzCustomDir := filepath.Join(homeDir, ".oh-my-zsh/custom/themes")
	if err := mkdirAll(omzCustomDir, 0755); err != nil {
		slog.Info("跳过主题安装", "reason", "oh-my-zsh 未安装")
	} else {
		themeDst := filepath.Join(omzCustomDir, "use-custom.zsh-theme")

		// 检查主题文件是否存在
		if _, err := os.Stat(themeDst); err == nil && !*force {
			slog.Info("主题已存在，跳过", "theme", "use-custom.zsh-theme")
		} else {
			data, err := zshConfig.ReadFile("zsh/theme/use-custom.zsh-theme")
			if err == nil {
				if err := writeFile(themeDst, data, 0644); err != nil {
					return fmt.Errorf("%w: 安装主题失败: %w", getError(ToolZsh, ActionConfig), err)
				}
				slog.Info("已安装 zsh 主题")
			}
		}
	}

	fmt.Println("\033[36mStep3: 安装插件\033[0m")
	omzPluginsDir := filepath.Join(homeDir, ".oh-my-zsh/custom/plugins")
	if err := mkdirAll(omzPluginsDir, 0755); err != nil {
		slog.Info("跳过插件安装", "reason", "oh-my-zsh 未安装")
	} else {
		for _, plugin := range plugins {
			pluginDir := filepath.Join(omzPluginsDir, plugin.name)
			if _, err := os.Stat(pluginDir); os.IsNotExist(err) || *force {
				if *force {
					os.RemoveAll(pluginDir)
				}
				slog.Info("正在安装插件...", "plugin", plugin.name)
				if err := execCmd("git", "clone", plugin.url, pluginDir); err != nil {
					slog.Info("安装插件失败", "plugin", plugin.name, "error", err.Error())
				} else {
					slog.Info("已安装", "plugin", plugin.name)
				}
			} else {
				slog.Info("插件已存在，跳过", "plugin", plugin.name)
			}
		}
	}

	fmt.Println("\033[36mStep4: 设置默认 shell\033[0m")
	output, err := exec.Command("sh", "-c", "echo $SHELL").Output()
	if err != nil {
		return fmt.Errorf("%w: 获取当前 shell 失败: %w", getError(ToolZsh, ActionConfig), err)
	}

	currentShell := strings.TrimSpace(string(output))
	if !strings.Contains(currentShell, "zsh") {
		// 检查是否是 root 用户
		if os.Getuid() == 0 {
			slog.Info("当前 shell 不是 zsh，正在切换...")
			if err := execCmd("chsh", "-s", "/bin/zsh"); err != nil {
				return fmt.Errorf("%w: 切换 shell 失败: %w", getError(ToolZsh, ActionConfig), err)
			}
			slog.Info("已切换到 zsh，重新登录后生效")
		} else {
			fmt.Println("\033[33m当前 shell 不是 zsh，请手动执行以下命令切换：\033[0m")
			fmt.Println("\033[32m  chsh -s /bin/zsh\033[0m")
			fmt.Println("\033[33m然后重新登录生效\033[0m")
		}
	} else {
		slog.Info("当前 shell 已经是 zsh")
	}

	fmt.Println("\033[36mStep5: 应用配置\033[0m")
	slog.Info("配置完成！执行 'source ~/.zshrc' 或重新打开终端应用配置")

	return nil
}

func vim() error {

	slog.Info("===========================================")
	slog.Info("正在配置 vim")
	slog.Info("===========================================")
	cfgErr := getError(ToolVim, ActionConfig)

	// todo：home 等公用变量获取一次，往下传递
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("%w: %w", cfgErr, err)
	}

	// Step1: 复制配置文件
	fmt.Println("\033[36mStep1: 配置文件\033[0m")
	vimrcPath := filepath.Join(homeDir, ".vimrc")
	if _, err := os.Stat(vimrcPath); os.IsNotExist(err) || *force {
		// 尝试读取 .vimrc，如果不存在则使用 simple._vimrc
		data, err := vimConfig.ReadFile("vim/.vimrc")
		if err != nil {
			data, err = vimConfig.ReadFile("vim/simple._vimrc")
			if err != nil {
				return fmt.Errorf("%w: 读取嵌入 vimrc 失败: %w", cfgErr, err)
			}
		}
		if err := writeFile(vimrcPath, data, 0644); err != nil {
			return fmt.Errorf("%w: 写入 .vimrc 失败: %w", cfgErr, err)
		}
		slog.Info("已复制 .vimrc", "path", vimrcPath)
	} else {
		slog.Info(".vimrc 已存在，跳过")
	}

	// Step2: 安装 vim-plug 插件管理器
	fmt.Println("\033[36mStep2: 安装插件管理器 vim-plug\033[0m")
	vimPlugPath := filepath.Join(homeDir, ".vim/autoload/plug.vim")
	vimPlugInstalled := false

	if _, err := os.Stat(vimPlugPath); os.IsNotExist(err) || *force {
		slog.Info("下载 vim-plug...")
		if err := mkdirAll(filepath.Dir(vimPlugPath), 0755); err != nil {
			return fmt.Errorf("%w: 创建 vim 目录失败: %w", cfgErr, err)
		}

		cmd := fmt.Sprintf("curl -fLo %s --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim", vimPlugPath)
		if err := execCmd("sh", "-c", cmd); err != nil {
			return fmt.Errorf("%w: 下载 vim-plug 失败: %w", cfgErr, err)
		}
		slog.Info("已安装", "tool", "vim-plug")
		vimPlugInstalled = true
	} else {
		slog.Info("vim-plug 已存在，跳过")
	}

	// Step3: 提示安装插件
	if vimPlugInstalled {
		fmt.Println("\033[36mStep3: 安装插件\033[0m")
		fmt.Println("\033[32m配置完成！打开 vim 执行 ':PlugInstall' 安装插件\033[0m")
	} else {
		fmt.Println("\033[32mvim 配置完成！\033[0m")
	}

	return nil
}

func git() error {

	slog.Info("===========================================")
	slog.Info("正在配置 git")
	slog.Info("===========================================")

	if *gitName == "" || *gitEmail == "" {
		slog.Warn("未指定 git 用户名或邮箱，将使用默认配置。建议使用 --git-name 和 --git-email 指定。")
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("%w: %w", getError(ToolGit, ActionConfig), err)
	}

	gitConfigPath := filepath.Join(homeDir, ".gitconfig")

	if _, err := os.Stat(gitConfigPath); err == nil && !*force {
		slog.Info("配置文件已存在，跳过", "path", gitConfigPath)
		return nil
	}

	data, err := gitConfig.ReadFile("git/.gitconfig")
	if err != nil {
		return fmt.Errorf("%w: 读取嵌入配置失败: %w", getError(ToolGit, ActionConfig), err)
	}

	content := string(data)
	if *gitName != "" {
		content = strings.ReplaceAll(content, "{{.User}}", fmt.Sprintf("name = %s", *gitName))
	}
	if *gitEmail != "" {
		content = strings.ReplaceAll(content, "{{.Email}}", fmt.Sprintf("email = %s", *gitEmail))
	}

	if err := writeFile(gitConfigPath, []byte(content), 0644); err != nil {
		return fmt.Errorf("%w: 写入文件失败: %w", getError(ToolGit, ActionConfig), err)
	}

	slog.Info("已复制配置文件", "path", gitConfigPath)
	return nil
}

// macosCustomize macOS
// 安装 raycast Rectangle Snipaste Monitorcontrol 等
func macosCustomize() error {

	osStr, err := conditionOS()
	if err != nil {
		return err
	}

	// 仅在 macOS 系统上执行
	if osStr != OSDarwin {
		return fmt.Errorf("当前系统不是 macos，跳过")
	}

	slog.Info("===========================================")
	slog.Info("正在执行 macOS 个性化配置")
	slog.Info("===========================================")

	// 忽略错误处理
	_ = execCmd("brew", "install", "raycast")
	_ = execCmd("brew", "install", "--cask", "rectangle")
	_ = execCmd("brew", "install", "--cask", "snipaste")
	_ = execCmd("brew", "install", "monitorcontrol")

	slog.Info("macOS 个性化配置完成")
	return nil
}

func _main() error {

	if !*configVim && !*configGit && !*configZsh && !*configMacos && !*configAll && !*configGvm && !*configJava && !*configRust {
		flag.Usage()
		return nil
	}

	// 显示配置概览
	var enabledConfigs []string
	if *configAll {
		enabledConfigs = append(enabledConfigs, "all")
	} else {
		if *configVim { enabledConfigs = append(enabledConfigs, "vim") }
		if *configGit { enabledConfigs = append(enabledConfigs, "git") }
		if *configZsh { enabledConfigs = append(enabledConfigs, "zsh") }
		if *configMacos { enabledConfigs = append(enabledConfigs, "macos") }
		if *configGvm { enabledConfigs = append(enabledConfigs, "gvm") }
		if *configJava { enabledConfigs = append(enabledConfigs, "java") }
		if *configRust { enabledConfigs = append(enabledConfigs, "rust") }
	}
	slog.Info("配置概览", "enabled", strings.Join(enabledConfigs, ", "), "force", *force, "dry-run", *dryRun)

	if *dryRun {
		slog.Info("========================================")
		slog.Info("       预览模式 (Dry Run)")
		slog.Info("  不会执行任何实际操作")
		slog.Info("========================================")
	}

	var (
		toolsToInstall []tools
		configFunc     []ExecFunc
	)

	if *configAll || *configGit {
		toolsToInstall = append(toolsToInstall, ToolGit)
		configFunc = append(configFunc, git)
	}

	if *configAll || *configVim {
		toolsToInstall = append(toolsToInstall, ToolVim)
		configFunc = append(configFunc, vim)
	}

	if *configAll || *configZsh || *configGvm || *configJava || *configRust {
		toolsToInstall = append(toolsToInstall, ToolZsh, ToolOMZ, ToolTheFuck, ToolBat, ToolFzf, ToolEza)
		if *configAll || *configGvm {
			toolsToInstall = append(toolsToInstall, ToolGvm)
		}
		if *configAll || *configJava {
			toolsToInstall = append(toolsToInstall, ToolSdkman)
		}
		if *configAll || *configRust {
			toolsToInstall = append(toolsToInstall, ToolRustup)
		}
		configFunc = append(configFunc, zsh)
	}

	if *configAll || *configMacos {
		configFunc = append(configFunc, macosCustomize)
	}

	// 检查安装
	slog.Info("===========================================")
	slog.Info("开始检查和安装工具", "total", len(toolsToInstall))
	slog.Info("===========================================")
	for i, tool := range toolsToInstall {
		slog.Info("检查工具", "step", fmt.Sprintf("%d/%d", i+1, len(toolsToInstall)), "tool", string(tool))
		if err := checkAndInstall(tool); err != nil {
			return err
		}
	}
	slog.Info("所有工具检查完成", "total", len(toolsToInstall))

	// 配置
	slog.Info("===========================================")
	slog.Info("开始应用配置", "total", len(configFunc))
	slog.Info("===========================================")
	for i, cfgFunc := range configFunc {
		slog.Info("应用配置", "step", fmt.Sprintf("%d/%d", i+1, len(configFunc)))
		if err := cfgFunc(); err != nil {
			return err
		}
	}
	slog.Info("所有配置应用完成", "total", len(configFunc))

	slog.Info("===========================================")
	slog.Info("配置完成！")
	slog.Info("===========================================")
	return nil
}
