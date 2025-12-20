# Ansible Role

Core system configuration role for workstation setup. Provides essential utilities and base system configuration used by all playbooks.

## Overview

The ansible role handles:

- System fact detection (WSL, OS family detection)
- Essential package installation
- SSH server installation and enablement for remote access

## Dependencies

- Requires sudo/root access for system package installation and user creation.

## Role Variables

All variables are defined in `defaults/main.yml` and can be overridden at the playbook or inventory level.

### SSH Key Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ansible_ssh_key` | Ed25519 key (manage key) | SSH public key for the `ansible` system user used for remote management. |

### SSH Server Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ansible_ssh_server_package` | `openssh` (Arch) / `openssh-server` (others) | SSH server package name to install. |
| `ansible_ssh_service_name` | `ssh` (Debian) / `sshd` (others) | SSH service name to enable and start. |

## Task Organization

```
tasks/
├── main.yml                   # Main entry point with task blocks
├── facts/
│   └── wsl_detection.yml      # Detect WSL environment
├── ssh.yml                    # Install/enable SSH server
└── software/
    └── packages_utilities.yml # Essential utilities (htop, tmux, zsh, etc.)
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

## Examples

### Usage
```bash
# Run ansible role via playbook
ansible-playbook ansible.yml -K
```

### Override the ansible SSH key
```yaml
# In a custom playbook or group_vars
---
- hosts: localhost
  connection: local
  vars:
    ansible_ssh_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFoo... your-ansible-key"
  roles:
    - ansible
```
