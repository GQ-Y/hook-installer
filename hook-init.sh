#!/bin/bash

# Hook MineAdmin 初始化安装脚本
# 版本: 1.0.0
# 作者: Hook Team
# 描述: 用于Linux系统的Hook MineAdmin初始化安装脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 仓库信息
HOOK_REPO_URL="https://github.com/GQ-Y/hook-mine-mangen.git"
HOOK_REPO_NAME="hook-mine-mangen"
INSTALL_DIR="/opt/hook-mineadmin"

# 打印函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 检查是否为root用户
check_root_permission() {
    print_header "🔐 权限检查"
    
    if [[ $EUID -ne 0 ]]; then
        print_error "此脚本需要root权限运行"
        echo -e "${YELLOW}请使用以下命令重新运行:${NC}"
        echo "  sudo bash hook-init.sh"
        exit 1
    fi
    
    print_success "Root权限验证通过"
}

# 检测操作系统
detect_os() {
    print_header "🖥️  操作系统检测"
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo -e "${WHITE}操作系统:${NC} $PRETTY_NAME"
        echo -e "${WHITE}版本:${NC} $VERSION_ID"
        echo -e "${WHITE}架构:${NC} $(uname -m)"
        
        # 检查是否为支持的Linux发行版
        case $ID in
            ubuntu|debian|centos|rhel|fedora|rocky|alma|amzn)
                print_success "支持的操作系统: $ID"
                OS_ID=$ID
                OS_VERSION=$VERSION_ID
                ;;
            *)
                print_warning "未明确测试的操作系统: $ID"
                echo -e "${YELLOW}脚本可能不完全兼容，建议使用Ubuntu 22.04+或CentOS 8+${NC}"
                OS_ID=$ID
                OS_VERSION=$VERSION_ID
                ;;
        esac
    else
        print_error "无法检测操作系统信息"
        exit 1
    fi
}

# 检测系统架构
detect_architecture() {
    print_header "🏗️  系统架构检测"
    
    ARCH=$(uname -m)
    echo -e "${WHITE}系统架构:${NC} $ARCH"
    
    case $ARCH in
        x86_64|amd64)
            print_success "x86_64 架构 - 完全支持"
            ;;
        aarch64|arm64)
            print_success "ARM64 架构 - 完全支持"
            ;;
        armv7l)
            print_warning "ARMv7 架构 - 基本支持"
            ;;
        *)
            print_warning "未知架构 $ARCH - 可能不兼容"
            ;;
    esac
}

# 检测内存
detect_memory() {
    print_header "💾 内存检测"
    
    local mem_total=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
    echo -e "${WHITE}总内存:${NC} ${mem_total}GB"
    
    if [[ $mem_total -ge 2 ]]; then
        print_success "内存充足 (≥2GB)"
    else
        print_warning "内存较少 (<2GB)，建议至少2GB内存"
    fi
}

# 检测磁盘空间
detect_disk_space() {
    print_header "💿 磁盘空间检测"
    
    local available_space=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')
    echo -e "${WHITE}可用磁盘空间:${NC} ${available_space}GB"
    
    if [[ $available_space -ge 5 ]]; then
        print_success "磁盘空间充足 (≥5GB)"
    else
        print_warning "磁盘空间较少 (<5GB)，建议至少5GB可用空间"
    fi
}

# 检测网络连接
detect_network() {
    print_header "🌐 网络连接检测"
    
    local github_url="https://github.com"
    local gitee_url="https://gitee.com"
    
    if curl -s --connect-timeout 5 "$github_url" &> /dev/null; then
        print_success "GitHub访问正常"
        GITHUB_ACCESSIBLE=true
    else
        print_warning "GitHub访问失败"
        GITHUB_ACCESSIBLE=false
    fi
    
    if curl -s --connect-timeout 5 "$gitee_url" &> /dev/null; then
        print_success "Gitee访问正常"
        GITEE_ACCESSIBLE=true
    else
        print_warning "Gitee访问失败"
        GITEE_ACCESSIBLE=false
    fi
    
    if [[ "$GITHUB_ACCESSIBLE" == false && "$GITEE_ACCESSIBLE" == false ]]; then
        print_error "无法访问GitHub和Gitee，请检查网络连接"
        exit 1
    fi
}

# 检测Git
detect_git() {
    print_header "📦 Git检测"
    
    if command -v git &> /dev/null; then
        local git_version=$(git --version 2>/dev/null | cut -d' ' -f3)
        print_success "Git已安装，版本: $git_version"
        GIT_INSTALLED=true
    else
        print_warning "Git未安装"
        GIT_INSTALLED=false
    fi
}

# 检测curl
detect_curl() {
    print_header "🌐 Curl检测"
    
    if command -v curl &> /dev/null; then
        local curl_version=$(curl --version 2>/dev/null | head -n1 | cut -d' ' -f2)
        print_success "Curl已安装，版本: $curl_version"
        CURL_INSTALLED=true
    else
        print_warning "Curl未安装"
        CURL_INSTALLED=false
    fi
}

# 更新系统包
update_system() {
    print_header "🔄 系统更新"
    
    case $OS_ID in
        ubuntu|debian)
            print_info "更新Ubuntu/Debian系统包..."
            apt-get update -y
            if [[ $? -eq 0 ]]; then
                print_success "系统包更新完成"
            else
                print_warning "系统包更新失败，继续执行..."
            fi
            ;;
        centos|rhel|rocky|alma|fedora)
            print_info "更新CentOS/RHEL系统包..."
            if command -v dnf &> /dev/null; then
                dnf update -y
            else
                yum update -y
            fi
            if [[ $? -eq 0 ]]; then
                print_success "系统包更新完成"
            else
                print_warning "系统包更新失败，继续执行..."
            fi
            ;;
        amzn)
            print_info "更新Amazon Linux系统包..."
            yum update -y
            if [[ $? -eq 0 ]]; then
                print_success "系统包更新完成"
            else
                print_warning "系统包更新失败，继续执行..."
            fi
            ;;
        *)
            print_warning "未知操作系统，跳过系统更新"
            ;;
    esac
}

# 安装必要工具
install_essential_tools() {
    print_header "🔧 安装必要工具"
    
    local tools_to_install=""
    
    # 检查并添加需要安装的工具
    if [[ "$GIT_INSTALLED" == false ]]; then
        tools_to_install="$tools_to_install git"
    fi
    
    if [[ "$CURL_INSTALLED" == false ]]; then
        tools_to_install="$tools_to_install curl"
    fi
    
    if [[ -z "$tools_to_install" ]]; then
        print_success "所有必要工具已安装"
        return 0
    fi
    
    print_info "需要安装的工具: $tools_to_install"
    
    case $OS_ID in
        ubuntu|debian)
            print_info "使用apt-get安装工具..."
            apt-get install -y $tools_to_install
            ;;
        centos|rhel|rocky|alma|fedora)
            print_info "使用包管理器安装工具..."
            if command -v dnf &> /dev/null; then
                dnf install -y $tools_to_install
            else
                yum install -y $tools_to_install
            fi
            ;;
        amzn)
            print_info "使用yum安装工具..."
            yum install -y $tools_to_install
            ;;
        *)
            print_error "不支持的操作系统，无法自动安装工具"
            echo -e "${YELLOW}请手动安装以下工具:${NC} $tools_to_install"
            exit 1
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        print_success "工具安装完成"
    else
        print_error "工具安装失败"
        exit 1
    fi
}

# 创建安装目录
create_install_directory() {
    print_header "📁 创建安装目录"
    
    if [[ -d "$INSTALL_DIR" ]]; then
        print_warning "安装目录已存在: $INSTALL_DIR"
        echo -e "${YELLOW}是否删除现有目录并重新安装？(y/N):${NC}"
        read -r confirm_remove
        if [[ "$confirm_remove" =~ ^[Yy]$ ]]; then
            print_info "删除现有安装目录..."
            rm -rf "$INSTALL_DIR"
        else
            print_info "保留现有安装目录，跳过安装"
            return 0
        fi
    fi
    
    print_info "创建安装目录: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
    
    if [[ $? -eq 0 ]]; then
        print_success "安装目录创建成功"
    else
        print_error "安装目录创建失败"
        exit 1
    fi
}

# 克隆Hook仓库
clone_hook_repository() {
    print_header "📥 克隆Hook仓库"
    
    cd "$INSTALL_DIR"
    
    print_info "从 $HOOK_REPO_URL 克隆仓库..."
    
    if git clone "$HOOK_REPO_URL" "$HOOK_REPO_NAME" 2>/dev/null; then
        print_success "Hook仓库克隆成功"
    else
        print_error "Hook仓库克隆失败"
        echo -e "${YELLOW}可能的原因:${NC}"
        echo "  1. 网络连接问题"
        echo "  2. 仓库地址错误"
        echo "  3. 权限问题"
        exit 1
    fi
    
    # 进入仓库目录
    cd "$HOOK_REPO_NAME"
    
    # 检查mineadmin.sh脚本是否存在
    if [[ -f "docker/mineadmin.sh" ]]; then
        print_success "找到mineadmin.sh脚本"
    else
        print_error "未找到mineadmin.sh脚本"
        echo -e "${YELLOW}请检查仓库结构是否正确${NC}"
        exit 1
    fi
}

# 设置脚本权限
setup_script_permissions() {
    print_header "🔐 设置脚本权限"
    
    cd "$INSTALL_DIR/$HOOK_REPO_NAME"
    
    print_info "设置mineadmin.sh脚本执行权限..."
    chmod +x docker/mineadmin.sh
    
    if [[ $? -eq 0 ]]; then
        print_success "脚本权限设置成功"
    else
        print_error "脚本权限设置失败"
        exit 1
    fi
}

# 安装全局命令
install_global_command() {
    print_header "🔗 安装全局命令"
    
    cd "$INSTALL_DIR/$HOOK_REPO_NAME"
    
    print_info "执行mineadmin.sh setup命令..."
    
    # 执行setup命令
    if ./docker/mineadmin.sh setup; then
        print_success "全局命令安装成功"
    else
        print_error "全局命令安装失败"
        echo -e "${YELLOW}请手动执行:${NC}"
        echo "  cd $INSTALL_DIR/$HOOK_REPO_NAME"
        echo "  ./docker/mineadmin.sh setup"
        exit 1
    fi
}

# 显示安装完成信息
show_installation_complete() {
    print_header "🎉 安装完成"
    
    echo -e "${WHITE}✅ Hook MineAdmin 初始化安装完成！${NC}"
    echo ""
    echo -e "${WHITE}📁 安装位置:${NC}"
    echo "  $INSTALL_DIR/$HOOK_REPO_NAME"
    echo ""
    echo -e "${WHITE}🎯 可用命令:${NC}"
    echo "  hook help     - 查看帮助信息"
    echo "  hook check    - 检查系统兼容性"
    echo "  hook install  - 安装部署MineAdmin"
    echo "  hook init     - 从官方仓库初始化项目"
    echo "  hook init-hook - 从Hook仓库初始化项目"
    echo ""
    echo -e "${WHITE}📖 使用说明:${NC}"
    echo "  1. 运行 'hook help' 查看所有可用命令"
    echo "  2. 运行 'hook check' 检查系统兼容性"
    echo "  3. 运行 'hook init-hook' 初始化Hook项目"
    echo "  4. 运行 'hook install' 安装部署"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 主函数
main() {
    print_header "🚀 Hook MineAdmin 初始化安装脚本"
    echo -e "${WHITE}版本: 1.0.0${NC}"
    echo -e "${WHITE}描述: Linux系统环境检测和Hook仓库安装${NC}"
    echo ""
    
    # 执行各个步骤
    check_root_permission
    detect_os
    detect_architecture
    detect_memory
    detect_disk_space
    detect_network
    detect_git
    detect_curl
    update_system
    install_essential_tools
    create_install_directory
    clone_hook_repository
    setup_script_permissions
    install_global_command
    show_installation_complete
}

# 运行主函数
main "$@"
