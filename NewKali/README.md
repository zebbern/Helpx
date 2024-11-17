# AutoKali: Automated Kali Linux/Kali Setup

![License](https://img.shields.io/github/license/zebbern/NewKali)
![GitHub stars](https://img.shields.io/github/stars/zebbern/NewKali?style=social)
![GitHub forks](https://img.shields.io/github/forks/zebbern/NewKali?style=social)

## Overview

**NewKali** automates the setup of Kali Linux, optimizing it for bug bounty hunting and penetration testing. It ensures compatibility, installs essential tools, manages dependencies, and provides a user-friendly interface for managing help topics and scheduled tasks.

## Features

- **Python 3.11.x Management**
  - Ensures Python 3.11.x is installed, uninstalling Python 3.12.x if present.
- **Comprehensive Tool Installation**
  - Installs essential, recon, bug bounty, and web exploitation tools (`nmap`, `masscan`, `subfinder`, `amass`, `gobuster`, `ffuf`, etc.).
- **Go-Based Tools**
  - Installs `waybackurls`, `nuclei`, `httpx`, `assetfinder`, `gau`, `httprobe`, `hackerone-recon`.
- **Browser Automation**
  - Installs `Puppeteer` and `Playwright`.
- **Helpx Command**
  - Create, view, and manage help topics.
- **Cron Job Management**
  - Easily view, add, and remove cron jobs via `helpx -cron`.
- **Auto-Updating Mechanisms**
  - Schedules updates for critical tools like `nuclei` templates.
- **System Cleanup**
  - Removes unnecessary packages to optimize performance.
- **Shell Compatibility**
  - Supports both `bash` and `zsh`, automatically configuring the appropriate shell.

## Installation

### Prerequisites

- Fresh Kali Linux installation
- Internet connection
- Sudo or root access

### Steps

1. **Clone the Repository**
    ```bash
    git clone https://github.com/zebbern/AutoKali.git
    cd AutoKali
    ```

2. **Make the Script Executable**
    ```bash
    chmod +x setup.sh
    ```

3. **Run the Setup Script**
    ```bash
    sudo ./setup.sh
    ```

    The script will:
    - Detect your shell (`bash` or `zsh`)
    - Update and upgrade system packages
    - Manage Python versions
    - Install essential tools and libraries
    - Set up `helpx` and cron job management
    - Clean up unnecessary packages
    - Prompt for system restart

## Usage

### Helpx Command

Provides an interactive menu to manage help topics and cron jobs.

- **View Help Topics**
    ```bash
    helpx
    ```
    Displays available help topics and usage instructions.

- **Create a New Help Topic**
    ```bash
    helpx create
    ```
    - Enter the topic name (e.g., `nmap`)
    - Edit the created file at `~/.helptopics/nmap.txt`

- **View a Specific Help Topic**
    ```bash
    helpx nmap
    ```
    Displays the content of `~/.helptopics/nmap.txt`

- **Manage Cron Jobs**
    ```bash
    helpx -cron
    ```
    - **Options:**
      1. View current cron jobs
      2. Add a new cron job
      3. Remove a cron job
      4. Exit

### Managing Cron Jobs

Use `helpx -cron` to manage scheduled tasks easily:
- **View Cron Jobs:** Lists all current cron jobs.
- **Add Cron Job:** Prompts for schedule and command.
- **Remove Cron Job:** Removes a selected cron job.

## Troubleshooting

### Python Installation Issues

1. **Ensure Deadsnakes PPA is Added**
    ```bash
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt update -y
    ```

2. **Manually Install Python 3.11.x**
    ```bash
    sudo apt install -y python3.11 python3.11-venv python3.11-dev
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
    sudo update-alternatives --set python3 /usr/bin/python3.11
    ```

### Helpx Command Not Found

1. **Source Shell Configuration**
    ```bash
    source ~/.bashrc
    # or
    source ~/.zshrc
    ```

2. **Verify Helpx Function in RC File**
    Ensure `helpx` function is correctly defined in your `.bashrc` or `.zshrc`.

### Cron Job Issues

1. **Check Cron Service**
    ```bash
    sudo systemctl status cron
    sudo systemctl start cron
    ```

2. **Review Cron Logs**
    ```bash
    grep CRON /var/log/syslog
    ```

## Contributing

Contributions are welcome! Follow these steps:

1. **Fork the Repository**
2. **Create a Feature Branch**
    ```bash
    git checkout -b feature/YourFeature
    ```
3. **Commit Your Changes**
    ```bash
    git commit -m "Add Your Feature"
    ```
4. **Push to the Branch**
    ```bash
    git push origin feature/YourFeature
    ```
5. **Open a Pull Request**

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

- **GitHub:** [zebbern](https://github.com/zebbern)
- **Email:** [your-email@example.com](mailto:your-email@example.com)

---

> **Disclaimer:** Use this script responsibly. Ensure you have proper authorization before performing penetration testing or bug bounty activities on any systems or networks.
