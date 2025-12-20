# Velez Role

Primary user configuration role for the workstation account. Creates and configures the primary interactive user and SSH access.

## Overview

The velez role handles:

- Primary user creation
- SSH key provisioning for the primary user
- Sudo group membership

## Role Variables

All variables are defined in `defaults/main.yml` and can be overridden at the playbook or inventory level.

| Variable | Default | Description |
|----------|---------|-------------|
| `primary_user` | `velez` | Name of the primary interactive user account to create and configure. |
| `primary_user_home` | `/home/{{ primary_user }}` | Home directory of the primary user. |
| `primary_user_ssh_key` | Ed25519 key (identity key) | SSH public key for the primary user account. |

## Examples

### Run via playbook
```bash
ansible-playbook velez.yml -K
```

### Override the primary user
```yaml
---
- hosts: localhost
  connection: local
  vars:
    primary_user: "myuser"
    primary_user_home: "/home/myuser"
    primary_user_ssh_key: "ssh-ed25519 AAAAC3... your-key-here"
  roles:
    - velez
```
