# **UFW + Docker Firewall Manager: Configuration as Code.**

`udwall` is a lightweight, declarative tool to manage UFW and Docker firewall rules using a single Python configuration file. It fixes the Docker security flaw where containers bypass UFW, and it automates rule management so you never have to run manual `ufw allow` commands again.

## Why udwall?

Standard UFW and the existing `ufw-docker` tool are great, but they require manual maintenance. **udwall** fills the gap:

1.  **Configuration as Code:** Define your entire firewall state in one file (`udwall.conf`). If you migrate servers, just copy the file and apply.
2.  **True Synchronization:** `udwall` performs atomic updates. It calculates the difference between your config and the live system, removing old unused rules and applying new ones automatically.
3.  **Unified Syntax:** Manage Host rules (SSH) and Docker rules (Mapped Ports) in the same list. Just toggle `isDockerServed=True`.
4.  **Safety First:** Automatically backs up `/etc/ufw` and `iptables` before every change. Plus, it has hardcoded protections so you can't accidentally delete SSH and lock yourself out.
5.  **Reverse Engineering:** Already have a server set up? Run `udwall --create` to scan your live firewall and generate a config file instantly.

## Installation

You can install `udwall` with a single command:

```bash
curl -s https://raw.githubusercontent.com/Hexmos/udwall/main/install.sh | sudo bash
```

This script will:
- Check for dependencies (`python3`, `ufw`, `curl`).
- Download `udwall` to `/usr/local/bin/udwall`.
- Set up a default configuration at `/etc/udwall/udwall.conf`.

## Usage

**Note:** `udwall` requires `sudo` privileges.

### 1. Fix the Docker Flaw & Enable UFW

This sets up the `iptables` rules required to make Docker respect UFW.

```bash
sudo udwall --enable
```

### 2. Define your Rules

Edit the configuration file at `/etc/udwall/udwall.conf` (or `udwall.conf` in the current directory).

```python
# udwall.conf
rules = [
    # --- Host Rules ---
    # Always allow SSH (udwall protects this automatically, but good to be explicit)
    {'from': 'any', 'connectionType': 'tcp', 'to': '22', 'isDockerServed': False, 'isEnabled': True},
    # Nginx on Host
    {'from': 'any', 'connectionType': 'tcp', 'to': 80, 'isDockerServed': False, 'isEnabled': True},

    # --- Docker Rules ---
    # Container mapped to port 8080. 
    # 'isDockerServed': True handles the routing logic automatically.
    {'from': 'any', 'connectionType': 'tcp', 'to': 8080, 'isDockerServed': True, 'isEnabled': True},
    
    # Allow specific IP to access a database container
    {'from': '1.2.3.4', 'connectionType': 'tcp', 'to': 5432, 'isDockerServed': True, 'isEnabled': True},
]
```

### 3. Apply the Configuration

This will backup your current state, remove undefined rules, and apply the new ones.

```bash
sudo udwall --apply
```

### 4. Other Commands

| Command | Description |
| :--- | :--- |
| `sudo udwall --dry-run` | Shows what rules would be applied without making changes. |
| `sudo udwall --create` | Generates a `udwall.conf` from your current live rules. |
| `sudo udwall --backup` | Creates a timestamped backup in `/home/ubuntu/backup/`. |
| `sudo udwall --status` | Shows the current UFW status. |
| `sudo udwall --disable` | Removes Docker rules, cleans files, and disables UFW. |

## 🛡️ Credits

The core `iptables` logic to fix the Docker/UFW security flaw is based on the work by [chaifeng/ufw-docker](https://github.com/chaifeng/ufw-docker). `udwall` extends this by adding declarative state management.

## 📄 License

MIT
