package main

import (
	"embed"
	"errors"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

//go:embed git/.gitconfig
var gitConfig embed.FS

//go:embed vim/.vimrc vim/simple._vimrc
var vimConfig embed.FS

//go:embed zsh/.zshrc zsh/config/* zsh/theme/*
var zshConfig embed.FS

var (
	configVim *bool
	configGit *bool
	configZsh *bool
	configAll *bool
)

func init() {
	configVim = flag.Bool("vim", false, "配置 vim")
	configGit = flag.Bool("git", false, "配置 git")
	configZsh = flag.Bool("zsh", false, "配置 zsh")
	configAll = flag.Bool("all", false, "配置所有工具")
}

func main() {
	flag.Parse()

	if err := _main(); err != nil {
		panic(err)
	}
}

type action string

const (
	ActionCheck   action = "check"
	ActionInstall action = "install"
	ActionConfig  action = "config"
)

type osType string

const (
	OSLinux  osType = "linux"
	OSDarwin osType = "darwin"
	// not supported yet
	OSWindows osType = "windows"
)

type ExecFunc func() error

var (
	checkVimError     = errors.New("检查 vim 安装失败")
	checkGitError     = errors.New("检查 git 安装失败")
	checkTheFuckError = errors.New("检查 thefuck 安装失败")
	checkPythonError  = errors.New("检查 python 安装失败")
	checkZshError     = errors.New("检查 zsh 安装失败")
	checkOhMyZshError = errors.New("检查 oh-my-zsh 安装失败")
	checkPip3Error    = errors.New("检查 pip3 安装失败")
	checkEzaError     = errors.New("检查 eza 安装失败")
	checkFzfError     = errors.New("检查 fzf 安装失败")

	installVimError     = errors.New("安装 vim 失败")
	installGitError     = errors.New("安装 git 失败")
	installPythonError  = errors.New("安装 python 失败")
	installZshError     = errors.New("安装 zsh 失败")
	installTheFuckError = errors.New("安装 thefuck 失败")
	installOhMyZshError = errors.New("安装 oh-my-zsh 失败")
	installEzaError     = errors.New("安装 eza 失败")
	installFzfError     = errors.New("安装 fzf 失败")

	gitCfgError = errors.New("git 配置失败")
	zshCfgError = errors.New("zsh 配置失败")
	vimCfgError = errors.New("vim 配置失败")

	pkgManagerError = errors.New("无法检测到可用的包管理器")
	osError         = errors.New("不支持的操作系统")

	UnknownTool = errors.New("未知工具")
)

type tools string

const (
	ToolGit     tools = "git"
	ToolVim     tools = "vim"
	ToolPython  tools = "python3"
	ToolZsh     tools = "zsh"
	ToolOMZ     tools = "oh-my-zsh"
	ToolTheFuck tools = "thefuck"
	ToolEza     tools = "eza"
	ToolPip3    tools = "pip3"
	ToolFzf     tools = "fzf"
)

func getError(tool tools, act action) error {
	switch act {
	case ActionInstall:
		switch tool {
		case ToolGit:
			return installGitError
		case ToolVim:
			return installVimError
		case ToolPython:
			return installPythonError
		case ToolZsh:
			return installZshError
		case ToolTheFuck:
			return installTheFuckError
		case ToolOMZ:
			return installOhMyZshError
		case ToolEza:
			return installEzaError
		case ToolFzf:
			return installFzfError
		default:
			return UnknownTool
		}
	case ActionCheck:
		switch tool {
		case ToolGit:
			return checkGitError
		case ToolVim:
			return checkVimError
		case ToolPython:
			return checkPythonError
		case ToolTheFuck:
			return checkTheFuckError
		case ToolOMZ:
			return checkOhMyZshError
		case ToolZsh:
			return checkZshError
		case ToolEza:
			return checkEzaError
		case ToolPip3:
			return checkPip3Error
		case ToolFzf:
			return checkFzfError
		default:
			return UnknownTool
		}
	}

	return nil
}

func conditionOS() (osType, error) {

	switch runtime.GOOS {
	case string(OSLinux):
		return OSLinux, nil
	case string(OSDarwin):
		return OSDarwin, nil
	default:
		return "", osError
	}
}

func execCmd(cmd string, args ...string) error {

	command := exec.Command(cmd, args...)
	output, err := command.CombinedOutput()
	if err != nil {
		if len(output) > 0 {
			return fmt.Errorf("%w: %s", err, string(output))
		}
		return err
	}

	return nil
}

func getPackageManager() (string, []string, error) {

	osStr, err := conditionOS()
	if err != nil {
		return "", nil, err
	}

	switch osStr {
	case OSDarwin:
		return "brew", []string{"install"}, nil
	case OSLinux:
		if _, err := exec.LookPath("apt"); err == nil {
			return "apt", []string{"install", "-y"}, nil
		} else if _, err := exec.LookPath("yum"); err == nil {
			return "yum", []string{"install", "-y"}, nil
		} else if _, err := exec.LookPath("dnf"); err == nil {
			return "dnf", []string{"install", "-y"}, nil
		} else if _, err := exec.LookPath("pacman"); err == nil {
			return "pacman", []string{"-S", "--noconfirm"}, nil
		}
		return "", nil, pkgManagerError
	default:
		return "", nil, osError
	}
}

func checkFunc(cmdName tools, errMsg error) ExecFunc {

	return func() error {

		if cmdName == "oh-my-zsh" {
			homeDir, err := os.UserHomeDir()
			if err != nil {
				return fmt.Errorf("%w: %w", errMsg, err)
			}
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

		if pkgName == ToolOMZ {
			// oh-my-zsh 需要通过脚本安装
			installCmd := `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended`
			if err := execCmd("zsh", "-c", installCmd); err != nil {
				return fmt.Errorf("%w: %w", errMsg, err)
			}
			slog.Info("已安装", "tool", "oh-my-zsh")
			return nil
		}

		pm, args, err := getPackageManager()
		if err != nil {
			return fmt.Errorf("获取包管理器失败: %w", err)
		}

		fullArgs := append(args, string(pkgName))
		if err := execCmd(pm, fullArgs...); err != nil {
			return fmt.Errorf("%w: %w", errMsg, err)
		}
		slog.Info("已安装", "tool", string(pkgName))
		return nil
	}
}

func checkAndInstall(tool tools) error {

	if err := checkFunc(tool, getError(tool, ActionCheck))(); err != nil {
		slog.Info("正在安装", "tool", string(tool))
		return installFunc(tool, getError(tool, ActionInstall))()
	}
	slog.Info("已存在", "tool", string(tool))
	return nil
}

func zsh() error {

	slog.Info("正在配置 zsh...")

	fmt.Println("\033[36mStep1: 配置文件\033[0m")
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("%w: %w", zshCfgError, err)
	}

	// 复制 .zshrc
	zshrcPath := filepath.Join(homeDir, ".zshrc")
	// 备份旧文件（如果存在）
	if _, err := os.Stat(zshrcPath); err == nil {
		backupPath := zshrcPath + ".backup"
		if err := os.Rename(zshrcPath, backupPath); err != nil {
			slog.Info("备份旧配置失败", "error", err.Error())
		} else {
			slog.Info("已备份旧配置", "path", backupPath)
		}
	}

	input, err := zshConfig.ReadFile("zsh/.zshrc")
	if err != nil {
		return fmt.Errorf("%w: 读取嵌入 .zshrc 失败: %w", zshCfgError, err)
	}
	if err := os.WriteFile(zshrcPath, input, 0644); err != nil {
		return fmt.Errorf("%w: 写入 .zshrc 失败: %w", zshCfgError, err)
	}
	slog.Info("已复制 .zshrc", "path", zshrcPath)

	// 复制 config 目录
	configDir := filepath.Join(
		homeDir,
		fmt.Sprintf(".%s_env/%s", os.Getenv("USER"), ToolZsh),
	)
	if err := os.MkdirAll(configDir, 0755); err != nil {
		return fmt.Errorf("%w: 创建配置目录失败: %w", zshCfgError, err)
	}

	configFiles := []string{"aliases.zsh", "envs.zsh", "function.zsh", "fzf.zsh"}
	for _, file := range configFiles {
		src := filepath.Join("zsh/config", file)
		dst := filepath.Join(configDir, file)
		// 从嵌入文件读取
		data, err := zshConfig.ReadFile(src)
		if err != nil {
			slog.Info("跳过文件", "file", file, "reason", "读取失败")
			continue
		}
		if err := os.WriteFile(dst, data, 0644); err != nil {
			return fmt.Errorf("%w: 写入配置文件 %s 失败: %w", zshCfgError, file, err)
		}
	}
	slog.Info("已复制 zsh 配置文件", "count", len(configFiles))

	fmt.Println("\033[36mStep2: 安装主题\033[0m")
	omzCustomDir := filepath.Join(homeDir, ".oh-my-zsh/custom/themes")
	if err := os.MkdirAll(omzCustomDir, 0755); err != nil {
		slog.Info("跳过主题安装", "reason", "oh-my-zsh 未安装")
	} else {
		themeDst := filepath.Join(omzCustomDir, "use-custom.zsh-theme")
		data, err := zshConfig.ReadFile("zsh/theme/use-custom.zsh-theme")
		if err == nil {
			if err := os.WriteFile(themeDst, data, 0644); err != nil {
				return fmt.Errorf("%w: 安装主题失败: %w", zshCfgError, err)
			}
			slog.Info("已安装 zsh 主题")
		}
	}

	fmt.Println("\033[36mStep3: 安装插件\033[0m")
	omzPluginsDir := filepath.Join(homeDir, ".oh-my-zsh/custom/plugins")
	if err := os.MkdirAll(omzPluginsDir, 0755); err != nil {
		slog.Info("跳过插件安装", "reason", "oh-my-zsh 未安装")
	} else {
		// 安装 zsh-autosuggestions
		autoSuggestDir := filepath.Join(omzPluginsDir, "zsh-autosuggestions")
		if _, err := os.Stat(autoSuggestDir); os.IsNotExist(err) {
			slog.Info("正在安装 zsh-autosuggestions...")
			if err := execCmd("git", "clone", "https://github.com/zsh-users/zsh-autosuggestions", autoSuggestDir); err != nil {
				slog.Info("安装 zsh-autosuggestions 失败", "error", err.Error())
			} else {
				slog.Info("已安装", "plugin", "zsh-autosuggestions")
			}
		} else {
			slog.Info("zsh-autosuggestions 已存在，跳过")
		}

		// 安装 zsh-syntax-highlighting
		syntaxHighlightDir := filepath.Join(omzPluginsDir, "zsh-syntax-highlighting")
		if _, err := os.Stat(syntaxHighlightDir); os.IsNotExist(err) {
			slog.Info("正在安装 zsh-syntax-highlighting...")
			if err := execCmd("git", "clone", "https://github.com/zsh-users/zsh-syntax-highlighting.git", syntaxHighlightDir); err != nil {
				slog.Info("安装 zsh-syntax-highlighting 失败", "error", err.Error())
			} else {
				slog.Info("已安装", "plugin", "zsh-syntax-highlighting")
			}
		} else {
			slog.Info("zsh-syntax-highlighting 已存在，跳过")
		}
	}

	fmt.Println("\033[36mStep4: 设置默认 shell\033[0m")
	output, err := exec.Command("sh", "-c", "echo $SHELL").Output()
	if err != nil {
		return fmt.Errorf("%w: 获取当前 shell 失败: %w", zshCfgError, err)
	}

	currentShell := strings.TrimSpace(string(output))
	if !strings.Contains(currentShell, "zsh") {
		// 检查是否是 root 用户
		if os.Getuid() == 0 {
			slog.Info("当前 shell 不是 zsh，正在切换...")
			if err := execCmd("chsh", "-s", "/bin/zsh"); err != nil {
				return fmt.Errorf("%w: 切换 shell 失败: %w", zshCfgError, err)
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

	slog.Info("正在配置 vim...")

	// Step1: 复制配置文件
	fmt.Println("\033[36mStep1: 配置文件\033[0m")
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("%w: %w", vimCfgError, err)
	}

	// 复制 .vimrc
	vimrcPath := filepath.Join(homeDir, ".vimrc")
	if _, err := os.Stat(vimrcPath); os.IsNotExist(err) {
		input, err := vimConfig.ReadFile("vim/.vimrc")
		if err != nil {
			// 如果 .vimrc 不存在，尝试使用 simple._vimrc
			input, err = vimConfig.ReadFile("vim/simple._vimrc")
			if err != nil {
				return fmt.Errorf("%w: 读取嵌入 vimrc 失败: %w", vimCfgError, err)
			}
		}
		if err := os.WriteFile(vimrcPath, input, 0644); err != nil {
			return fmt.Errorf("%w: 写入 .vimrc 失败: %w", vimCfgError, err)
		}
		slog.Info("已复制 .vimrc", "path", vimrcPath)
	} else {
		slog.Info(".vimrc 已存在，跳过")
	}

	// Step2: 安装 vim-plug 插件管理器
	fmt.Println("\033[36mStep2: 安装插件管理器 vim-plug\033[0m")
	vimPlugPath := filepath.Join(homeDir, ".vim/autoload/plug.vim")
	vimPlugInstalled := false
	if _, err := os.Stat(vimPlugPath); os.IsNotExist(err) {
		slog.Info("下载 vim-plug...")
		// 创建目录
		if err := os.MkdirAll(filepath.Dir(vimPlugPath), 0755); err != nil {
			return fmt.Errorf("%w: 创建 vim 目录失败: %w", vimCfgError, err)
		}
		// 下载 vim-plug
		cmd := "curl -fLo " + vimPlugPath + " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
		if err := execCmd("sh", "-c", cmd); err != nil {
			return fmt.Errorf("%w: 下载 vim-plug 失败: %w", vimCfgError, err)
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

	slog.Info("正在配置 git...")

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("%w: %w", gitCfgError, err)
	}

	// 检查用户目录下是否有 .gitconfig 文件
	gitconfigPath := filepath.Join(homeDir, ".gitconfig")
	if _, err := os.Stat(gitconfigPath); os.IsNotExist(err) {
		input, err := gitConfig.ReadFile("git/.gitconfig")
		if err != nil {
			return fmt.Errorf("%w: 读取嵌入配置失败: %w", gitCfgError, err)
		}
		if err := os.WriteFile(gitconfigPath, input, 0644); err != nil {
			return fmt.Errorf("%w: 写入文件失败: %w", gitCfgError, err)
		}
		slog.Info("已复制 .gitconfig", "path", gitconfigPath)
	} else {
		slog.Info(".gitconfig 已存在，跳过配置")
	}

	return nil
}

func _main() error {

	if !*configVim && !*configGit && !*configZsh && !*configAll {
		flag.Usage()
		return nil
	}

	var (
		toolsToInstall []tools
		configFuncs    []ExecFunc
	)

	if *configAll || *configGit {
		toolsToInstall = append(toolsToInstall, ToolGit)
		configFuncs = append(configFuncs, git)
	}

	if *configAll || *configVim {
		toolsToInstall = append(toolsToInstall, ToolVim)
		configFuncs = append(configFuncs, vim)
	}

	if *configAll || *configZsh {
		toolsToInstall = append(toolsToInstall, ToolZsh, ToolOMZ, ToolPython, ToolTheFuck)
		configFuncs = append(configFuncs, zsh)
	}

	// 检查安装
	slog.Info("开始检查和安装工具...")
	for _, tool := range toolsToInstall {
		if err := checkAndInstall(tool); err != nil {
			return err
		}
	}

	// 配置
	slog.Info("开始配置...")
	for _, cfgFunc := range configFuncs {
		if err := cfgFunc(); err != nil {
			return err
		}
	}

	slog.Info("所有配置完成！")
	return nil
}
