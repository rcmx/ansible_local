# ansible_local
Ansible playbooks for workstation configuration and management.

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

## New Machine Setup

Complete guide for configuring a fresh machine from scratch.

### Minimum Prerequisites

**Only two things are required** before running the playbooks:

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y ansible git

# Fedora/RHEL
sudo dnf install -y ansible git

# Arch Linux
sudo pacman -S ansible git
```

### Run Configuration

```bash
# Clone and run the setup you want
git clone https://github.com/rcmx/ansible_local.git
cd ansible_local

# Ansible system user + core system config
ansible-playbook ansible.yml -K

# Add primary user configuration on top
ansible-playbook velez.yml -K

# Add development tooling on top
ansible-playbook dev.yml -K
```

**That's it!** After running the appropriate playbook, the playbooks handle everything else including:
- Creating the `ansible` system user for remote management
- Creating the primary user and SSH access (when using `velez.yml` or `dev.yml`)
- Installing required packages
- Configuring system settings

## Quick Start

```bash
# Clone the repository
git clone https://github.com/rcmx/ansible_local.git
cd ansible_local

# Ansible system user + core system config
ansible-playbook ansible.yml -K
```

## Available Playbooks

```bash
# List all available playbooks
ls *.yml

# Current playbooks:
# - ansible.yml         : Ansible user + core system configuration
# - velez.yml           : Primary user configuration (includes ansible role)
# - dev.yml             : Development tools (includes ansible + velez roles)
```

## Running Playbooks

### Manual Execution
```bash
# Ansible system user + core system config
ansible-playbook ansible.yml -K

# Primary user setup (includes ansible)
ansible-playbook velez.yml -K

# Development setup (includes ansible + velez)
ansible-playbook dev.yml -K

# Test syntax without changes
ansible-playbook --syntax-check ansible.yml
ansible-playbook --syntax-check velez.yml
ansible-playbook --syntax-check dev.yml
```

## Architecture

- **ansible.yml**: Ansible system user + core system configuration
- **velez.yml**: Primary user configuration (includes ansible role)
- **dev.yml**: Development tools (includes ansible + velez roles)
- **roles/ansible/**: Core system configuration role
- **roles/velez/**: Primary user configuration role
- **roles/dev/**: Development tools and configurations role
