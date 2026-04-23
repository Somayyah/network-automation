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

    **..TODO**

    Automate ansible user creation using bootstrap.sh:

    ```bash
    curl -s https://raw.githubusercontent.com/somayyah/network-automation/main/bootstrap.sh | bash
    ```