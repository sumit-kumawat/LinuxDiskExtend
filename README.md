🚀 Auto Disk Extender
A powerful, automated disk extension script for Linux LVM systems that automatically detects and utilizes unallocated disk space or creates new partitions when additional storage is added in virtual environments like Proxmox, VMware, or Hyper-V.

📋 Table of Contents
Features

Supported Systems

Quick Start

Usage

How It Works

Manual Commands

Integration with Proxmox

Troubleshooting

Contributing

License

✨ Features
🔍 Automatic Detection - Finds unused partitions and unallocated space

🤖 Fully Automated - No manual intervention required

🛡️ Safe Operations - Non-destructive to existing data

📊 Comprehensive Logging - Color-coded output with timestamps

🔧 Multi-Filesystem Support - XFS and ext4 filesystems

⚡ One-Command Solution - Simple execution, complex operations

🎯 Smart Partitioning - Automatically creates optimal partitions

📈 Pre/Post Verification - Shows disk space before and after extension

🖥️ Supported Systems
Distributions: AlmaLinux, Rocky Linux, CentOS, RHEL, Ubuntu, Debian

Virtualization: Proxmox, VMware, Hyper-V, KVM, Xen

Filesystems: XFS, ext4

Storage: LVM-managed disks

🚀 Quick Start
Installation
bash
# Download and install
curl -L -o /usr/local/bin/auto_extend_disk.sh https://raw.githubusercontent.com/yourusername/auto-disk-extender/main/auto_extend_disk.sh
chmod +x /usr/local/bin/auto_extend_disk.sh

# Or clone the repository
git clone https://github.com/yourusername/auto-disk-extender.git
cd auto-disk-extender
chmod +x auto_extend_disk.sh
sudo cp auto_extend_disk.sh /usr/local/bin/
Basic Usage
bash
# Run the automated script
sudo auto_extend_disk.sh

# Or from current directory
sudo ./auto_extend_disk.sh
📖 Usage
Full Automation
bash
sudo auto_extend_disk.sh
The script will automatically:

Check current disk usage

Detect unused partitions

Find unallocated space

Create new partitions if needed

Extend LVM logical volumes

Resize filesystems

Display before/after results

Verbose Mode
bash
# For detailed output
sudo auto_extend_disk.sh --verbose

# Or with debug information
sudo auto_extend_disk.sh --debug
Dry Run Mode
bash
# See what would be done without making changes
sudo auto_extend_disk.sh --dry-run
🔧 How It Works
Process Flow
text
1. Pre-flight Checks
   │
2. Disk Space Analysis
   │
3. Unused Partition Detection
   │
4. Free Space Assessment
   │
5. Partition Creation (if needed)
   │
6. LVM Extension
   │
7. Filesystem Resize
   │
8. Verification & Reporting
Sequence Diagram
🛠️ Manual Commands
Quick One-liner
bash
sudo bash -c 'for p in /dev/sda[0-9]*; do [[ -b "$p" ]] && ! pvs | grep -q "$p" && { pvcreate $p && vgextend almalinux $p && lvextend -l +100%FREE /dev/mapper/almalinux-root && xfs_growfs /dev/mapper/almalinux-root && echo "✅ Success: $(df -h / | awk "NR==2{print \$2}")" && exit 0; }; done; echo "❌ No unused partitions"'
Manual Partition + Extension
bash
# Create partition using parted
sudo parted -s /dev/sda mkpart primary 0% 100%
sudo parted -s /dev/sda set 3 lvm on
sudo partprobe /dev/sda

# Extend LVM
sudo pvcreate /dev/sda3
sudo vgextend almalinux /dev/sda3
sudo lvextend -l +100%FREE /dev/mapper/almalinux-root
sudo xfs_growfs /dev/mapper/almalinux-root
☁️ Integration with Proxmox
Automated Proxmox Hook
Create a script that runs after VM disk extension in Proxmox:

bash
# /etc/pve/hookscripts/disk-extend.sh
#!/bin/bash
if [ "$1" == "post-disk-extend" ]; then
    ssh root@$2 "auto_extend_disk.sh"
fi
Cron Job for Periodic Checking
bash
# Add to crontab (crontab -e)
# Check every 5 minutes for disk changes
*/5 * * * * /usr/local/bin/auto_extend_disk.sh --cron
🐛 Troubleshooting
Common Issues
1. "No free space available"

bash
# Check disk layout
sudo fdisk -l /dev/sda
sudo lsblk

# Verify in Proxmox that disk was actually extended
2. "Partition not found after creation"

bash
# Force kernel to reread partition table
sudo partprobe -s /dev/sda
sudo blockdev --rereadpt /dev/sda

# Or reboot the system
sudo reboot
3. "Physical volume already exists"

bash
# Remove and recreate PV
sudo pvremove /dev/sda3
sudo pvcreate /dev/sda3
Debug Mode
bash
# Run with full debug output
sudo bash -x auto_extend_disk.sh

# Check system logs
sudo dmesg | grep sda
sudo journalctl -u lvm2-*
Verification Commands
bash
# Check disk layout
sudo lsblk
sudo fdisk -l /dev/sda

# Check LVM status
sudo pvs
sudo vgs
sudo lvs

# Check filesystem
sudo df -hT
sudo xfs_info /dev/mapper/almalinux-root  # For XFS
sudo tune2fs -l /dev/mapper/almalinux-root  # For ext4
🤝 Contributing
We welcome contributions! Please see our Contributing Guide for details.

Development Setup
bash
git clone https://github.com/yourusername/auto-disk-extender.git
cd auto-disk-extender

# Test the script
chmod +x auto_extend_disk.sh
sudo ./auto_extend_disk.sh --dry-run
Reporting Issues
Please report bugs and feature requests on the GitHub Issues page.

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

⚠️ Disclaimer
Always backup your data before performing disk operations. While this script is designed to be safe and non-destructive, the authors are not responsible for any data loss or system damage that may occur.

