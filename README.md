# Hook MineAdmin 初始化安装脚本

一个用于Linux系统的Hook MineAdmin自动化初始化安装脚本。

## 🚀 快速开始

### 一键安装（推荐）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/GQ-Y/hook-installer/main/hook-init.sh)"
```

### 手动下载安装

```bash
# 下载脚本
curl -fsSL https://raw.githubusercontent.com/GQ-Y/hook-installer/main/hook-init.sh -o hook-init.sh

# 设置执行权限
chmod +x hook-init.sh

# 运行脚本（需要root权限）
sudo bash hook-init.sh
```

## 📋 系统要求

- **操作系统**: Ubuntu 22.04+, CentOS 8+, RHEL 8+, Rocky Linux 8+, AlmaLinux 8+, Fedora, Amazon Linux 2
- **架构**: x86_64, ARM64, ARMv7
- **内存**: 至少2GB RAM
- **磁盘空间**: 至少5GB可用空间
- **权限**: Root权限（sudo）

## 🔧 功能特性

- ✅ **自动环境检测**: 检测操作系统、架构、内存、磁盘空间
- ✅ **网络连接检测**: 检测GitHub和Gitee访问状态
- ✅ **工具自动安装**: 自动安装Git、curl等必要工具
- ✅ **系统包更新**: 自动更新系统包
- ✅ **仓库克隆**: 自动克隆Hook MineAdmin仓库
- ✅ **全局命令安装**: 自动安装hook全局命令
- ✅ **权限管理**: 自动设置脚本执行权限

## 📦 安装内容

脚本会自动安装以下内容：

- Hook MineAdmin管理工具
- 全局`hook`命令
- 完整的项目结构

## 🎯 安装后的可用命令

安装完成后，您可以使用以下命令：

```bash
hook help        # 查看帮助信息
hook check       # 检查系统兼容性
hook install     # 安装部署MineAdmin
hook init        # 从官方仓库初始化项目
hook init-hook   # 从Hook仓库初始化项目
hook start       # 启动服务
hook stop        # 停止服务
hook status      # 查看服务状态
```

## 📁 安装位置

默认安装位置：`/opt/hook-mineadmin/hook-mine-mangen`

## 🔍 检测项目

脚本会检测以下项目：

1. **权限检查**: 验证是否为root用户
2. **操作系统检测**: 识别Linux发行版和版本
3. **架构检测**: 检测CPU架构（x86_64/ARM64/ARMv7）
4. **内存检测**: 检查系统内存大小
5. **磁盘空间检测**: 检查可用磁盘空间
6. **网络连接检测**: 检测GitHub和Gitee访问
7. **工具检测**: 检查Git和curl是否安装
8. **系统更新**: 更新系统包
9. **工具安装**: 安装缺失的必要工具

## 🛠️ 故障排除

### 常见问题

1. **权限不足**
   ```bash
   # 确保使用root权限运行
   sudo bash hook-init.sh
   ```

2. **网络连接问题**
   - 检查网络连接
   - 确保可以访问GitHub
   - 如果GitHub不可用，脚本会提示使用Gitee

3. **磁盘空间不足**
   - 清理不必要的文件
   - 确保至少5GB可用空间

4. **Git未安装**
   - 脚本会自动安装Git
   - 如果自动安装失败，请手动安装

### 手动安装工具

如果自动安装失败，可以手动安装必要工具：

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y git curl
```

**CentOS/RHEL/Rocky/Alma:**
```bash
sudo yum install -y git curl
# 或
sudo dnf install -y git curl
```

**Amazon Linux:**
```bash
sudo yum install -y git curl
```

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📞 支持

如果您遇到问题，请：

1. 查看[故障排除](#故障排除)部分
2. 提交[GitHub Issue](https://github.com/GQ-Y/hook-installer/issues)
3. 联系开发团队

---

**注意**: 此脚本需要root权限运行，请确保您了解脚本的功能和影响。
