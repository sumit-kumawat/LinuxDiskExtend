cat > /usr/local/bin/auto_extend_disk.sh << 'EOF'
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Variables
VG_NAME="almalinux"
LV_NAME="root"
DISK="/dev/sda"
FS_TYPE="xfs"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
   exit 1
fi

log "Starting automated disk extension process..."

# Function to check available disk space
check_disk_space() {
    log "Checking current disk space:"
    df -hT / | awk 'NR==1 || NR==2'
    echo
    log "LVM Status:"
    pvs 2>/dev/null && vgs 2>/dev/null && lvs 2>/dev/null
    echo
}

# Function to find next available partition
find_next_partition() {
    local last_part=$(fdisk -l $DISK 2>/dev/null | grep "^/dev" | tail -1 | cut -d' ' -f1)
    if [[ -z "$last_part" ]]; then
        echo "1"
    else
        local last_num=$(echo $last_part | sed 's/.*\([0-9]\)$/\1/')
        echo $((last_num + 1))
    fi
}

# Function to create new partition
create_partition() {
    local part_num=$1
    log "Creating new partition ${DISK}${part_num}"
    
    # Create partition using parted (non-interactive)
    if command -v parted >/dev/null 2>&1; then
        parted -s $DISK mkpart primary $(parted -s $DISK print free | grep "Free Space" | tail -1 | awk '{print $1" "$2}') || {
            error "Failed to create partition with parted"
            return 1
        }
        parted -s $DISK set $part_num lvm on
    else
        # Fallback to fdisk with expect
        {
            echo n
            echo p
            echo $part_num
            echo 
            echo 
            echo t
            echo $part_num
            echo 8e
            echo w
        } | fdisk $DISK >/dev/null 2>&1 || {
            error "Failed to create partition with fdisk"
            return 1
        }
    fi
    
    # Reload partition table
    partprobe $DISK >/dev/null 2>&1
    sleep 2
    
    # Verify partition exists
    if [[ -b "${DISK}${part_num}" ]]; then
        log "Successfully created ${DISK}${part_num}"
        return 0
    else
        error "Partition ${DISK}${part_num} not found after creation"
        return 1
    fi
}

# Function to extend LVM
extend_lvm() {
    local partition=$1
    
    log "Extending LVM with $partition"
    
    # Create physical volume
    if ! pvcreate $partition >/dev/null 2>&1; then
        error "Failed to create physical volume on $partition"
        return 1
    fi
    log "Created physical volume: $partition"
    
    # Extend volume group
    if ! vgextend $VG_NAME $partition >/dev/null 2>&1; then
        error "Failed to extend volume group $VG_NAME"
        return 1
    fi
    log "Extended volume group: $VG_NAME"
    
    # Extend logical volume
    if ! lvextend -l +100%FREE /dev/mapper/${VG_NAME}-${LV_NAME} >/dev/null 2>&1; then
        error "Failed to extend logical volume"
        return 1
    fi
    log "Extended logical volume: ${VG_NAME}-${LV_NAME}"
    
    # Resize filesystem
    case $FS_TYPE in
        "xfs")
            if ! xfs_growfs /dev/mapper/${VG_NAME}-${LV_NAME} >/dev/null 2>&1; then
                error "Failed to grow XFS filesystem"
                return 1
            fi
            ;;
        "ext4")
            if ! resize2fs /dev/mapper/${VG_NAME}-${LV_NAME} >/dev/null 2>&1; then
                error "Failed to resize ext4 filesystem"
                return 1
            fi
            ;;
        *)
            error "Unsupported filesystem: $FS_TYPE"
            return 1
            ;;
    esac
    log "Resized $FS_TYPE filesystem"
    
    return 0
}

# Main execution
main() {
    log "=== Disk Extension Automation ==="
    check_disk_space
    
    # Check for existing unallocated partitions
    for part in ${DISK}[0-9]*; do
        if [[ -b "$part" ]]; then
            if ! pvs | grep -q "$part"; then
                log "Found unused partition: $part"
                if extend_lvm "$part"; then
                    log "Successfully extended using existing partition $part"
                    check_disk_space
                    exit 0
                fi
            fi
        fi
    done
    
    # Check for free space to create new partition
    local next_part=$(find_next_partition)
    if [[ -n "$next_part" ]]; then
        log "No unused partitions found. Creating new partition..."
        if create_partition $next_part; then
            if extend_lvm "${DISK}${next_part}"; then
                log "✅ Disk extension completed successfully!"
                check_disk_space
                exit 0
            fi
        fi
    else
        error "No free space available for new partition"
    fi
    
    error "Disk extension failed"
    exit 1
}

# Run main function
main "$@"
EOF

# Make it executable
chmod +x /usr/local/bin/auto_extend_disk.sh
