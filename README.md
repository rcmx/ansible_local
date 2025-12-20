# ansible_local
Ansible playbooks for workstation configuration and management using ansible-pull automation.

## Prerequisites

Before running the playbooks, you need to install Ansible and Git on your system.

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y ansible git
```

### Fedora/RHEL
```bash
sudo dnf install -y ansible git
```

### Arch Linux
```bash
sudo pacman -S ansible git
```

Verify installation:
```bash
ansible --version
```

## Quick Start

```bash
# Clone the repository
git clone https://github.com/rcmx/ansible_local.git
cd ansible_local

# Basic system setup (includes bootstrap automatically)
ansible-playbook basic.yml -K
```

## Available Playbooks

```bash
# List all available playbooks
ls *.yml

# Current playbooks:
# - basic.yml          : Basic system setup (includes bootstrap, users, packages, dotfiles)
# - dev.yml            : Development tools (includes basic + nodejs, docker, dotnet)
# - setup/bootstrap.yml: Creates ansible user (called automatically by basic.yml)
```

## Running Playbooks

### Manual Execution
```bash
# Basic system setup (includes bootstrap)
ansible-playbook basic.yml -K

# Development setup (includes basic)
ansible-playbook dev.yml -K

# Test syntax without changes
ansible-playbook --syntax-check basic.yml
```

### Automated Execution (ansible-pull)
```bash
# Basic setup via ansible-pull
ansible-pull -o -K -U https://github.com/rcmx/ansible_local.git basic.yml

# Development setup via ansible-pull
ansible-pull -o -K -U https://github.com/rcmx/ansible_local.git dev.yml
```

## Architecture

- **basic.yml**: Basic system configuration, users, and essential packages (includes bootstrap automatically)
- **dev.yml**: Development tools (depends on basic role automatically)
- **setup/bootstrap.yml**: Creates `ansible` system user (called automatically by basic.yml)
- **roles/basic/**: Basic system configuration role
- **roles/dev/**: Development tools and configurations role

The basic role sets up automated ansible-pull via cron every 10 minutes to maintain system configuration.



