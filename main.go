package main

import (
	"errors"
	"fmt"
	"log/slog"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

func main() {

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

	installVimError     = errors.New("安装 vim 失败")
	installGitError     = errors.New("安装 git 失败")
	installPythonError  = errors.New("安装 python 失败")
	installZshError     = errors.New("安装 zsh 失败")
	installTheFuckError = errors.New("安装 thefuck 失败")
	installOhMyZshError = errors.New("安装 oh-my-zsh 失败")

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
	slog.Info("exec cmd", "cmd", cmd, "args", args)

	return command.Run()
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
		if execCmd("command", "-v", "apt") == nil {
			return "apt", []string{"install", "-y"}, nil
		} else if execCmd("command", "-v", "yum") == nil {
			return "yum", []string{"install", "-y"}, nil
		} else if execCmd("command", "-v", "dnf") == nil {
			return "dnf", []string{"install", "-y"}, nil
		} else if execCmd("command", "-v", "pacman") == nil {
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
				slog.Error(err.Error())
				return fmt.Errorf("%w: %w", errMsg, err)
			}
			omzPath := filepath.Join(homeDir, ".oh-my-zsh")
			if _, err := os.Stat(omzPath); os.IsNotExist(err) {
				return fmt.Errorf("%w: oh-my-zsh not found", errMsg)
			}
			return nil
		}

		if err := execCmd("command", "-v", string(cmdName)); err != nil {
			slog.Error(err.Error())
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
				slog.Error(err.Error())
				return fmt.Errorf("%w: %w", errMsg, err)
			}
			return nil
		}

		if pkgName == ToolTheFuck {
			// the fuck 通过 pip 安装
			if err := checkFunc("pip3", checkPip3Error)(); err != nil {
				slog.Error(err.Error())
				// 先 panic
				panic(err)
			}
			if err := execCmd("pip3", "install", "-y", "thefuck"); err != nil {
				slog.Error(err.Error())
				panic(err)
			}
			return nil
		}

		pm, args, err := getPackageManager()
		if err != nil {
			slog.Error(err.Error())
			return fmt.Errorf("获取包管理器失败: %w", err)
		}

		fullArgs := append(args, string(pkgName))
		if err := execCmd(pm, fullArgs...); err != nil {
			slog.Error(err.Error())
			return fmt.Errorf("%w: %w", errMsg, err)
		}
		return nil
	}
}

func checkAndInstall(tool tools) error {

	if err := checkFunc(tool, getError(tool, ActionCheck))(); err != nil {

		slog.Info("Check&Install", "tool", string(tool), "msg", "未安装，正在安装...")
		return installFunc(tool, getError(tool, ActionInstall))()
	}

	return nil
}

func zsh() error {

	slog.Info("正在配置 zsh...")

	// Step1: 复制配置文件
	slog.Info("Step1: 配置文件")
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("%w: %w", zshCfgError, err)
	}

	// 复制 .zshrc
	zshrcPath := filepath.Join(homeDir, ".zshrc")
	if _, err := os.Stat(zshrcPath); os.IsNotExist(err) {
		src := "zsh/.zshrc"
		input, err := os.ReadFile(src)
		if err != nil {
			return fmt.Errorf("%w: 读取 .zshrc 失败: %w", zshCfgError, err)
		}
		if err := os.WriteFile(zshrcPath, input, 0644); err != nil {
			return fmt.Errorf("%w: 写入 .zshrc 失败: %w", zshCfgError, err)
		}
		slog.Info("已复制 .zshrc", "path", zshrcPath)
	} else {
		slog.Info(".zshrc 已存在，跳过")
	}

	// 复制 config 目录
	configDir := filepath.Join(
		homeDir,
		fmt.Sprintf("%s_env/%s", os.Getenv("USER"), ToolZsh),
	)
	if err := os.MkdirAll(configDir, 0755); err != nil {
		return fmt.Errorf("%w: 创建配置目录失败: %w", zshCfgError, err)
	}

	configFiles := []string{"aliases.zsh", "envs.zsh", "function.zsh", "fzf.zsh"}
	for _, file := range configFiles {
		src := filepath.Join("zsh/config", file)
		dst := filepath.Join(configDir, file)
		data, err := os.ReadFile(src)
		if err != nil {
			slog.Info("跳过文件", "file", file, "reason", "读取失败")
			continue
		}
		if err := os.WriteFile(dst, data, 0644); err != nil {
			return fmt.Errorf("%w: 写入配置文件 %s 失败: %w", zshCfgError, file, err)
		}
	}

	// Step2: 安装主题
	slog.Info("Step2: 安装主题")
	omzCustomDir := filepath.Join(homeDir, ".oh-my-zsh/custom/themes")
	if err := os.MkdirAll(omzCustomDir, 0755); err != nil {
		slog.Info("跳过主题安装", "reason", "oh-my-zsh 未安装")
	} else {
		themeSrc := "zsh/themes/yz.zsh-theme"
		themeDst := filepath.Join(omzCustomDir, "yz.zsh-theme")
		data, err := os.ReadFile(themeSrc)
		if err == nil {
			if err := os.WriteFile(themeDst, data, 0644); err != nil {
				return fmt.Errorf("%w: 安装主题失败: %w", zshCfgError, err)
			}
			slog.Info("已安装 zsh 主题")
		}
	}

	// Step3: 设置默认 shell
	slog.Info("Step3: 设置默认 shell")
	output, err := exec.Command("sh", "-c", "echo $SHELL").Output()
	if err != nil {
		return fmt.Errorf("%w: 获取当前 shell 失败: %w", zshCfgError, err)
	}

	currentShell := strings.TrimSpace(string(output))
	if !strings.Contains(currentShell, "zsh") {
		slog.Info("当前 shell 不是 zsh，正在切换...")
		if err := execCmd("chsh", "-s", "/bin/zsh"); err != nil {
			return fmt.Errorf("%w: 切换 shell 失败: %w", zshCfgError, err)
		}
		slog.Info("已切换到 zsh，重新登录后生效")
	} else {
		slog.Info("当前 shell 已经是 zsh")
	}

	// Step4: 提示用户
	slog.Info("Step4: 应用配置")
	slog.Info("配置完成！执行 'source ~/.zshrc' 或重新打开终端应用配置")

	return nil
}

func vim() error {

	slog.Info("正在配置 vim...")

	// Step1: 复制配置文件
	slog.Info("Step1: 配置文件")
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("%w: %w", vimCfgError, err)
	}

	// 复制 .vimrc
	vimrcPath := filepath.Join(homeDir, ".vimrc")
	if _, err := os.Stat(vimrcPath); os.IsNotExist(err) {
		src := "vim/.vimrc"
		input, err := os.ReadFile(src)
		if err != nil {
			// 如果 .vimrc 不存在，尝试使用 simple._vimrc
			src = "vim/simple._vimrc"
			input, err = os.ReadFile(src)
			if err != nil {
				return fmt.Errorf("%w: 读取 vimrc 失败: %w", vimCfgError, err)
			}
		}
		if err := os.WriteFile(vimrcPath, input, 0644); err != nil {
			return fmt.Errorf("%w: 写入 .vimrc 失败: %w", vimCfgError, err)
		}
		slog.Info("已复制 .vimrc", "path", vimrcPath)
	} else {
		slog.Info(".vimrc 存在，跳过")
	}

	// Step2: 安装 vim-plug 插件管理器
	slog.Info("Step2: 安装插件管理器 vim-plug")
	vimPlugPath := filepath.Join(homeDir, ".vim/autoload/plug.vim")
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
		slog.Info("vim-plug 安装成功")
	} else {
		slog.Info("vim-plug 已安装，跳过")
	}

	// Step3: 提示安装插件
	slog.Info("Step3: 安装插件")
	slog.Info("配置完成！打开 vim 执行 ':PlugInstall' 安装插件")

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
		// 复制默认配置文件到用户目录
		src := "git/.gitconfig"
		input, err := os.ReadFile(src)
		if err != nil {
			return fmt.Errorf("%w: 读取源文件失败: %w", gitCfgError, err)
		}
		if err := os.WriteFile(gitconfigPath, input, 0644); err != nil {
			return fmt.Errorf("%w: 写入文件失败: %w", gitCfgError, err)
		}
		slog.Info("已复制 git/.gitconfig", "path", gitconfigPath)
	} else {
		slog.Info(".gitconfig 已存在，跳过配置")
	}

	return nil
}

func _main() error {

	// 检查安装
	tools := []tools{ToolGit, ToolVim, ToolZsh, ToolOMZ, ToolPython, ToolTheFuck}
	for _, tool := range tools {
		if err := checkAndInstall(tool); err != nil {
			return err
		}
	}

	// 配置
	cfgFuncs := []ExecFunc{git, vim, zsh}
	for _, cfgFu := range cfgFuncs {
		if err := cfgFu(); err != nil {
			return err
		}
	}

	return nil
}
