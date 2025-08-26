# EasyCert - Interactive Local CA & Wildcard SSL Generator

[![GitHub stars](https://img.shields.io/github/stars/Ilia-Shakeri/EasyCert?style=social)](https://github.com/Ilia-Shakeri/EasyCert/stargazers)

EasyCert is an interactive Bash script that helps you create a local Certificate Authority (CA) and generate wildcard SSL certificates for your domain and optional subdomains. It is optimized for use with Nginx, Traefik, or any system that supports PEM certificates.

---

## Features

- **Interactive Prompt:** Guides users step-by-step with suggested defaults.
- **Wildcard & Subdomain Support:** Create certificates for `*.example.com` and additional custom subdomains.
- **Spinner Animation:** Visual feedback for long-running operations.
- **Logging:** Detailed log file next to the generated certificates including trust instructions.
- **Trust Instructions:** Full instructions for Windows, macOS, and Linux.
- **Colorful & Informative Messages:** Easy-to-read and friendly terminal messages.
- **Summary at End:** Displays all relevant certificate information.
- **Error Handling:** Basic validation for inputs and critical operations.
- **Customizable Paths & Expiry:** Specify output path, container name, and certificate expiry.

---

## Requirements

- Bash
- OpenSSL
- Docker (for restarting Nginx/Traefik container)
- sudo privileges

---

## Usage

```bash
git clone https://github.com/Ilia-Shakeri/ٍEasyCert.git
cd EasyCert
chmod +x EasyCert.sh
./EasyCert.sh
