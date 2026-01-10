# Dev Role

Development environment setup for workstation configuration. Provides programming languages, containerization, development tools, and terminal enhancements.

## Overview

The dev role extends the core role with comprehensive development tools. It includes:

- Node.js via system package manager
- .NET SDK (versions 8.0 and 9.0)
- Docker and Docker Compose
- Development utilities (neovim, curl)
- Nerd fonts for terminal icons
- Development language support

## Dependencies

- Run after the `ansible` and `velez` roles in the same play to ensure base system setup and primary user configuration are in place.
- Requires sudo/root access for package installation and service management.

## Role Variables

All variables are defined in `defaults/main.yml` and can be overridden at the playbook or inventory level.

### Node.js

Node.js is installed using the system package manager for each OS. No role variables are required.

### Fonts Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `fonts_to_install` | `[Hack]` | List of Nerd fonts to install system-wide. |

**Available fonts in Nerd Fonts release:**
- Common choices: `Hack`, `FiraCode`, `JetBrainsMono`, `Inconsolata`, `SourceCodePro`

**Usage:**
```yaml
- hosts: localhost
  vars:
    fonts_to_install:
      - Hack
      - FiraCode
      - JetBrainsMono
  roles:
    - dev
```

**Note:** Fonts are downloaded from the Nerd Fonts GitHub releases and installed to `/usr/local/share/fonts/`.

### Development Packages

The dev packages vary by OS but provide core development tools:

| Variable | Debian/Ubuntu | RedHat/Fedora | Arch Linux |
|----------|---------------|---------------|-----------|
| Development tools | `build-essential` | `@development-tools` | `base-devel` |
| Editor | `neovim` | `neovim` | `neovim` |
| Utilities | `curl` | `curl` | `curl` |

These are installed as prerequisites for development work.

### .NET SDK

| Variable | Default | Description |
|----------|---------|-------------|
| Versions | `8.0, 9.0` | .NET SDK versions to install |

**To customize installed versions**, modify the task in `roles/dev/tasks/software/dotnet.yml`:
```yaml
- name: software | dotnet | install dotnet SDK
  package:
    name:
      - dotnet-sdk-8.0
      - dotnet-sdk-9.0
    state: present
```

### Docker Configuration

Docker is installed with the following plugins:
- `docker-ce` - Docker Community Edition
- `docker-ce-cli` - Docker CLI
- `containerd.io` - Container runtime
- `docker-buildx-plugin` - Advanced build plugin
- `docker-compose-plugin` - Docker Compose v2

The primary user (default: `velez`, configurable via `primary_user`) is automatically added to the `docker` group to enable passwordless Docker command execution.

## Handlers

### Restart docker service

- **Listen:** `restart docker`
- **When triggered:** When Docker daemon configuration is modified
- **Action:** Restarts the Docker service to apply configuration changes
- **Skipped in:** WSL environments (use Docker Desktop for Windows)

**Usage in tasks:**
```yaml
- name: Configure docker daemon
  copy:
    src: daemon.json
    dest: /etc/docker/daemon.json
  notify: restart docker
```

## Task Organization

Tasks are organized by tool/feature:

```
tasks/
├── main.yml                    # Main entry point with task ordering
├── software/
│   ├── dev_packages.yml        # Base development packages (curl, neovim)
│   ├── dotnet.yml              # .NET SDK installation
│   ├── docker.yml              # Docker and Docker Compose
│   ├── fonts/
│   │   └── download-font.yml   # Nerd fonts installation
│   └── nodejs.yml              # Node.js via package manager
└── fonts/
    ├── download-font.yml       # Font downloading
    └── install-fonts.yml       # Font system installation
```

## Installation Details

### Node.js (via package manager)

The role installs Node.js and npm using the OS package manager.
Version updates follow your distro's package repositories.

### .NET SDK

Installs multiple .NET versions to support different projects:

**Debian/Ubuntu:**
- Adds Microsoft package repository
- Adds Microsoft GPG key for package verification
- Installs specified SDK versions

**RedHat/Fedora:**
- Adds Microsoft RPM repository
- Installs specified SDK versions

**Arch Linux:**
- Installs `dotnet-sdk` from community repositories
- Automatically gets latest .NET SDK

**Usage:**
```bash
# Check installed versions
dotnet --list-sdks

# Create new project
dotnet new console -n MyApp
cd MyApp
dotnet build
dotnet run
```

### Docker

Installs Docker with proper service configuration:

1. **Installs Docker** and dependencies
2. **Starts and enables** Docker service for auto-startup
3. **Creates docker group** for non-root access
4. **Adds velez user** to docker group (may require re-login)

**Verification:**
```bash
# Check Docker installation
docker --version

# Test Docker access
docker ps

# If permission denied, log out and back in, then:
docker ps
```

**Note:** In WSL environments, Docker installation is skipped (use Docker Desktop for Windows).

### Nerd Fonts

Downloads and installs Nerd Fonts for terminal icon support:

1. **Downloads** fonts from Nerd Fonts GitHub releases
2. **Extracts** to `/usr/local/share/fonts/{FontName}/`
3. **Updates font cache** for system recognition

**Terminal compatibility:**
- ZSH with proper font: Shows icons in file listings
- Tmux with proper font: Shows special characters
- Vim/Neovim with proper font: Displays plugin icons
- WezTerm: Built-in Nerd Font support

**Configuration:**
```bash
# In your terminal, set font to one of installed fonts:
# e.g., "Hack Nerd Font Mono" or "FiraCode Nerd Font"
```

## Platform-Specific Behavior

### WSL (Windows Subsystem for Linux)

The following components are **skipped** in WSL:
- Docker installation (use Docker Desktop for Windows instead)
- WezTerm installation (from core role)

All other development tools are installed normally.

**Detection:** Automatic via `is_wsl` fact from ansible role

### Ubuntu/Debian

- Uses `apt` package manager
- Adds third-party PPAs/repositories for some tools
- Supports latest versions through repository channels

### Fedora/RHEL

- Uses `dnf` package manager (or `yum` on older systems)
- Uses COPR repositories for community packages
- Uses RPM release packages directly from vendors

### Arch Linux

- Uses `pacman` package manager
- Access to AUR (Arch User Repository) for additional tools
- Generally bleeding-edge package versions

## User Permissions

After running this role, the primary user (default: `velez`) has:

- **Docker access:** Added to `docker` group (allows running Docker without `sudo`)
- **SSH access:** Configured with provisioned SSH key via `primary_user_ssh_key`
- **Shell:** ZSH with development configurations sourced
- **Development tools:** Full access to installed SDKs and utilities
- **Node.js:** Managed via the system package manager

**Note:** After adding the primary user to the `docker` group, they may need to log out and back in for group membership to take effect.

**Customization:**
The primary user is configurable via the `primary_user` variable (inherited from the velez role):
```yaml
vars:
  primary_user: "developer"  # Create/configure a different user
```

## Examples

### Usage
```bash
# Run dev playbook (includes ansible + velez roles)
ansible-playbook dev.yml -K
```

### Customize Installed Fonts
```yaml
# Custom playbook with different fonts
---
- hosts: localhost
  connection: local
  vars:
    fonts_to_install:
      - Hack
      - FiraCode
      - JetBrainsMono
      - SourceCodePro
  roles:
    - dev
```

### Run Only Specific Tasks
```bash
# Only install development packages
ansible-playbook dev.yml -K --tags dev_packages

# Only setup Docker
ansible-playbook dev.yml -K --tags docker

# Only install fonts
ansible-playbook dev.yml -K --tags fonts

# Skip Docker (useful on WSL)
ansible-playbook dev.yml -K --skip-tags docker
```

## Troubleshooting

### Docker Permission Denied

After installing Docker:
```bash
# Verify velez is in docker group
groups velez

# If docker group not listed, re-run the role
# Or manually add user to docker group:
sudo usermod -aG docker velez

# Log out and back in for group membership to take effect
exit
# Log back in
docker ps
```

### .NET SDK Not Found

```bash
# Verify installation
dotnet --list-sdks

# If no SDKs shown, check package installation:
# Ubuntu/Debian
apt list --installed | grep dotnet

# RedHat/Fedora
dnf list installed | grep dotnet

# Arch Linux
pacman -Q | grep dotnet
```

### Fonts Not Appearing in Terminal

1. Verify fonts were installed:
   ```bash
   ls /usr/local/share/fonts/
   ```

2. Rebuild font cache:
   ```bash
   fc-cache -fv
   ```

3. Update terminal font settings to one of the installed fonts:
   - Example: "Hack Nerd Font Mono" or "FiraCode Nerd Font"

4. Restart terminal application

## Integration with Playbooks

The top-level playbooks run roles in this order:

- `ansible.yml`: `ansible`
- `velez.yml`: `ansible`, `velez`
- `dev.yml`: `ansible`, `velez`, `dev`

## See Also

- `ansible.yml` - Ansible system user + core system configuration
- `velez.yml` - Primary user configuration
- `README.md` - Main project documentation
