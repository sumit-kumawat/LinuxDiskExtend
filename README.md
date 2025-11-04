# 💾 Auto Disk Extender

[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

> One-command solution to automatically extend Linux disk space with LVM

## 🚀 One-Command Solution


```bash
# Run once and auto-delete (recommended for one-time use)
sudo bash -c 'curl -L https://raw.githubusercontent.com/sumit-kumawat/LinuxDiskExtend/main/auto_extend_disk.sh -o /tmp/auto_extend_disk.sh && chmod +x /tmp/auto_extend_disk.sh && /tmp/auto_extend_disk.sh && rm -f /tmp/auto_extend_disk.sh'

# Or install permanently (if you need to run multiple times)
sudo curl -L https://raw.githubusercontent.com/sumit-kumawat/LinuxDiskExtend/main/auto_extend_disk.sh -o /usr/local/bin/auto_extend_disk.sh && sudo chmod +x /usr/local/bin/auto_extend_disk.sh && sudo auto_extend_disk.sh'
