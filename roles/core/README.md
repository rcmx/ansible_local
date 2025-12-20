# Core Role

Base system configuration role for workstation setup. Provides essential system utilities, user management, and automation framework setup.

## Overview

The core role is the foundation of the system configuration. It must be run first before any other roles. It handles:

- System fact detection (WSL, OS family detection)
- User account creation and SSH key provisioning
- Essential package installation
- Terminal and shell configuration (tmux, vim, zsh)
- System automation via cron (ansible-pull every 10 minutes)
- Kitty terminal emulator setup
- Lazygit installation

## Dependencies

- `bootstrap` playbook must be run once first to create the `ansible` system user
- Requires sudo/root access for system package installation and user creation

## Role Variables

All variables are defined in `defaults/main.yml` and can be overridden at the playbook or inventory level.

### User Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `primary_user` | `velez` | Name of the primary interactive user account to create and configure. This is the main non-root user for the workstation. |
| `primary_user_home` | `/home/{{ primary_user }}` | Home directory of the primary user. Derived from `primary_user` variable. |

### SSH Key Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ansible_ssh_key` | Ed25519 key (manage key) | SSH public key for `ansible` automation user. Used for passwordless remote management. |
| `primary_user_ssh_key` | Ed25519 key (identity key) | SSH public key for the primary user account. Default is configured for the `velez` user but can be customized for any primary user. |

**Usage:**
```yaml
# Default usage (creates velez user with default key)
ansible-playbook core.yml -K

# To use a different primary user:
- hosts: localhost
  vars:
    primary_user: "myuser"
    primary_user_home: "/home/myuser"
    primary_user_ssh_key: "ssh-ed25519 AAAAC3... your-key-here"
  roles:
    - core

# To keep velez but update the SSH key:
- hosts: localhost
  vars:
    primary_user_ssh_key: "ssh-ed25519 AAAAC3... new-key-here"
  roles:
    - core
```

### Cron Service Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `cron_packages_debian` | `cron` | Package name for Debian/Ubuntu systems |
| `cron_packages_rhel` | `[cronie, crontabs]` | Packages for RedHat/Fedora systems |
| `cron_packages_arch` | `cronie` | Package for Arch Linux systems |

**Note:** The `cron_service` variable is automatically determined based on `ansible_facts["os_family"]`.

### Platform-Specific Behavior

The role detects and adapts to different platforms:

| Platform | Sudo Group | Cron Service | Package Manager |
|----------|-----------|--------------|-----------------|
| Ubuntu/Debian | `sudo` | `cron` | apt |
| Fedora/RHEL | `wheel` | `crond` | dnf |
| Arch Linux | `wheel` | `crond` | pacman |
| WSL | Same as base distro | Same as base distro | Same as base distro |

## Handlers

### Restart cron service

- **Listen:** `restart cron`
- **When triggered:** When cron configuration is modified
- **Action:** Restarts the cron service to apply changes

**Usage in tasks:**
```yaml
- name: Update cron config
  copy:
    src: my-cron-config
    dest: /etc/cron.d/my-config
  notify: restart cron
```

## Task Organization

Tasks are organized into logical blocks:

```
tasks/
├── main.yml                    # Main entry point with task blocks
├── facts/
│   └── wsl_detection.yml       # Detect WSL environment
├── software/
│   ├── lazygit.yml             # Git interface
│   ├── packages_utilities.yml   # Essential utilities (htop, tmux, vim, zsh, etc.)
│   └── wezterm.yml             # Terminal emulator
├── system_setup/
│   └── automation.yml          # Cron job setup for ansible-pull
└── users/
    ├── ansible.yml             # Primary user (velez) provisioning
    └── velez.yml               # Secondary user (velez) detailed setup with dotfiles
```

## Package Installation

### Debian/Ubuntu
- Base development: `build-essential`
- Utilities: `htop`, `mc`, `tmux`, `wget`, `zsh`, `git`, `luarocks`, `ripgrep`, `gcc`, `fzf`

### Fedora/RHEL
- Base development: `@development-tools`
- Utilities: Same as above (package names compatible)

### Arch Linux
- Base development: `base-devel`
- Utilities: Same as above

## Automation Setup

The role automatically configures `ansible-pull` via cron to run every 10 minutes:

```bash
# What gets installed
*/10 * * * * ansible-pull -o -U https://github.com/rcmx/ansible_local.git core.yml

# Frequency: Every 10 minutes
# User: ansible (system automation user)
# Repo: rcmx/ansible_local
# Keeps system in sync with repository configuration
```

**To customize the ansible-pull frequency**, modify `roles/core/tasks/system_setup/automation.yml`:
```yaml
- name: Install cron job for ansible-pull automation
  cron:
    user: ansible
    minute: "*/10"  # Change this value (e.g., "*/30" for every 30 minutes)
    job: "ansible-pull -o -U https://github.com/rcmx/ansible_local.git core.yml"
```

## User Accounts Created

### `ansible` user (system user)
- UID: 995 (system reserved range)
- Groups: `wheel` (RedHat/Arch) or `sudo` (Debian)
- Passwordless sudo enabled
- SSH key configured
- Purpose: Automated playbook execution via ansible-pull

**Created by:** `bootstrap.yml` playbook (run once)

### Primary User (default: `velez`, configurable via `primary_user`)
- Regular user account
- Groups: `adm`, `ansible`, plus `sudo` (Debian) or `wheel` (RedHat/Arch)
- Shell: `/bin/zsh`
- Dotfiles configured: `.zshrc`, `.vimrc`, `.tmux.conf`
- Terminal: Kitty installed (configuration managed separately)
- SSH key configured via `primary_user_ssh_key` variable
- Purpose: Primary interactive user account for workstation

**Created by:** `core.yml` playbook

**Customization:**
```yaml
# Create a different primary user by overriding the variable:
vars:
  primary_user: "myname"
  primary_user_home: "/home/myname"
  primary_user_ssh_key: "ssh-ed25519 AAAAC3... your-key"
```

## Configuration Files

The role copies dotfiles to the primary user home directory (configurable via `primary_user_home`):

| File | Source | Destination | Purpose |
|------|--------|-------------|---------|
| `.zshrc` | `roles/core/files/system_setup/zshrc` | `{{ primary_user_home }}/.zshrc` | Zsh shell configuration |
| `.vimrc` | `roles/core/files/system_setup/vimrc` | `{{ primary_user_home }}/.vimrc` | Vim editor configuration |
| `.tmux.conf` | `roles/core/files/system_setup/tmux.conf` | `{{ primary_user_home }}/.tmux.conf` | Tmux multiplexer configuration |

**Default:** Dotfiles are installed in `/home/velez/` when using the default `primary_user: velez` setting.

**Note:** Kitty terminal configuration is not managed by this role. Configure kitty separately at `~/.config/kitty/kitty.conf`.

## Examples

### Basic Usage
```bash
# Run core role via playbook
ansible-playbook core.yml -K

# Run with ansible-pull (after bootstrap)
ansible-pull -o -K -U https://github.com/rcmx/ansible_local.git core.yml
```

### Override SSH Keys
```yaml
# In a custom playbook or group_vars
---
- hosts: localhost
  connection: local
  vars:
    ansible_ssh_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFoo... your-ansible-key"
    velez_ssh_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBar... your-velez-key"
  roles:
    - core
```

### Skip WezTerm Installation
The role automatically skips WezTerm in WSL environments. To skip on native systems:
```bash
ansible-playbook core.yml -K --skip-tags wezterm
```

### Run Only Specific Tasks
```bash
# Only update packages
ansible-playbook core.yml -K --tags packages

# Only setup users
ansible-playbook core.yml -K --tags users

# Only configure automation
ansible-playbook core.yml -K --tags automation
```

## Troubleshooting

### WSL Detection Not Working
The role detects WSL by checking:
1. `/proc/version` for Microsoft/WSL strings
2. `/proc/sys/fs/binfmt_misc/WSLInterop` file existence
3. `WSL_DISTRO_NAME` environment variable

If detection fails, `is_wsl` will be `false` and WSL-only skips won't apply.

### Cron Job Not Running
1. Verify the `ansible` user exists: `getent passwd ansible`
2. Check cron is installed and running: `systemctl status cron` or `systemctl status crond`
3. Verify cron job: `sudo crontab -u ansible -l`
4. Check logs: `sudo journalctl -u cron` or `sudo journalctl -u crond`

### SSH Keys Not Working
1. Verify key files exist: `ls -la ~/.ssh/authorized_keys`
2. Check permissions (should be 600): `stat ~/.ssh/authorized_keys`
3. Verify SSH daemon is running: `systemctl status ssh` or `systemctl status sshd`

## Platform-Specific Notes

### WSL (Windows Subsystem for Linux)
- Kitty terminal installation is skipped (use Windows Terminal instead)
- Docker installation is skipped (use Docker Desktop for Windows instead)
- All other tools are installed normally
- `is_wsl` flag is automatically set to control conditional execution

### macOS
- This role is designed for Linux systems and is not tested on macOS
- Many package managers and paths differ on macOS

## See Also

- `dev.yml` - Development tools role (depends on this core role)
- `bootstrap.yml` - Bootstrap playbook to create ansible user
- `CLAUDE.md` - Project architecture and common commands
