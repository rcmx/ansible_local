# ansible_local
Ansible playbooks for workstation configuration and management using ansible-pull automation.

## Bootstrap Setup (First Time Only)

Before running any playbooks, you must bootstrap the system to create the `ansible` user:

```bash
# Clone the repository
git clone https://github.com/rcmx/ansible_local.git
cd ansible_local

# Bootstrap - creates ansible user for automation
ansible-playbook bootstrap.yml -K
```

## Available Playbooks

```bash
# List all available playbooks
ls *.yml

# Current playbooks:
# - bootstrap.yml  : Creates ansible user (run once)
# - core.yml       : Basic system setup (users, packages, dotfiles)
# - dev.yml        : Development tools (includes core + nodejs, docker, dotnet)
# - local.yml      : Legacy playbook (deprecated, use core.yml)
```

## Running Playbooks

### Manual Execution
```bash
# Core system setup
ansible-playbook core.yml -K

# Development setup (includes core)
ansible-playbook dev.yml -K

# Test syntax without changes
ansible-playbook --syntax-check core.yml
```

### Automated Execution (ansible-pull)
```bash
# Core setup via ansible-pull
ansible-pull -o -K -U https://github.com/rcmx/ansible_local.git core.yml

# Development setup via ansible-pull  
ansible-pull -o -K -U https://github.com/rcmx/ansible_local.git dev.yml
```

## Architecture

- **bootstrap.yml**: Creates `ansible` system user for automation
- **core.yml**: Basic system configuration, users, and essential packages
- **dev.yml**: Development tools (depends on core role automatically)
- **roles/core/**: Core system configuration role
- **roles/dev/**: Development tools and configurations role

The core role sets up automated ansible-pull via cron every 10 minutes to maintain system configuration.



