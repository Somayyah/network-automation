# network-automation

A collection of network automation scripts I built while exploring different use cases.

Devices were previously managed via NetBox, and some experiments used `.env` files for configuration.

**... UPDATE — 23/04/2026**

Shifting direction for this repo:

- Old network automation scripts are being archived for now.
- Moving focus to Ansible-based Linux automation and machine bootstrapping.
- Current goals:
    - Ensure required packages are installed
    - Clone important repositories (including dotfiles)
    - Apply dotfiles using [GNU Stow](https://tamerlan.dev/how-i-manage-my-dotfiles-using-gnu-stow/)
    - Build a reproducible Linux setup from scratch

This is now more of a personal system setup repo than a network automation playground. Old tools may be revisited later.

## Bootstrap workflow (Linux hosts for now)

This bootstrap script is intended for Linux-based systems and prepares them for Ansible management, it is not applicable to network devices or non-Linux systems. To start the script:


```bash
git clone https://github.com/somayyah/network-automation.git
cd network-automation
bash bootstrap.sh [TARGET IP OR HOSTNAME] [TARGET MACHINE USER] [EMAIL] [GITHUB USERNAME]
```

This will:

+ create the ansible user on the target machine with sudo privilages
+ install SSH public key authentication for passwordless access
+ configure env variables necessary for ansible

Once completed, the machine is ready for configuration via Ansible:

```bash
make setup
```