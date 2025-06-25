# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Playbook Execution
```bash
# Bootstrap system (run once to create ansible user)
ansible-playbook bootstrap.yml -K

# Core system setup
ansible-playbook core.yml -K

# Development setup (includes core automatically)
ansible-playbook dev.yml -K

# Syntax validation
ansible-playbook --syntax-check <playbook>.yml
```

### Automated Execution (ansible-pull)
```bash
# Core setup via ansible-pull
ansible-pull -o -K -U https://github.com/rcmx/ansible_local.git core.yml

# Development setup via ansible-pull
ansible-pull -o -K -U https://github.com/rcmx/ansible_local.git dev.yml
```

## Architecture Overview

This is an Ansible workstation configuration repository using ansible-pull automation. The structure follows a role-based architecture:

### Playbook Structure
- **bootstrap.yml**: Creates the `ansible` system user (uid 995) with sudo privileges - must be run once before other playbooks
- **core.yml**: Basic system configuration using the `core` role
- **dev.yml**: Development environment setup using the `dev` role (automatically includes `core` role as dependency)
- **local.yml**: Legacy playbook (deprecated in favor of core.yml)

### Role Architecture
- **roles/core/**: Base system configuration
  - Creates system users (ansible, velez)
  - Installs essential packages and utilities
  - Configures dotfiles (tmux, vim, zsh)
  - Sets up automated ansible-pull via cron (every 10 minutes)
  
- **roles/dev/**: Development tools (depends on core role)
  - Node.js via NVM
  - .NET Core SDK
  - Docker and development packages
  - Additional development utilities

### Multi-Platform Support
Both roles support Ubuntu/Debian and Fedora/RHEL systems with conditional tasks based on `ansible_os_family`.

### Automation
The core role automatically sets up a cron job that runs `ansible-pull` every 10 minutes to maintain system configuration, ensuring the workstation stays current with repository changes.

### User Management
- **ansible user**: System automation account with passwordless sudo
- **velez user**: Primary user account with configured dotfiles and shell environment

The bootstrap process creates the ansible user and installs an SSH key for remote management capabilities.