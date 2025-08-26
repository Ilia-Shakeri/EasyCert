# EasyCert - Interactive Local CA & Wildcard SSL Generator

[![GitHub stars](https://img.shields.io/github/stars/Ilia-Shakeri/EasyCert?style=social)](https://github.com/Ilia-Shakeri/EasyCert/stargazers)

Generate SSL certificates like a pro! `EasyCert` is an easy-to-use, fully interactive tool to create **local Certificate Authorities (CA)** and **wildcard SSL certificates** for your domain and optional subdomains. Perfect for developers, DevOps engineers, and anyone running **Nginx, Traefik, or local testing environments**.  

This script simplifies SSL setup with interactive prompts, auto-suggestions, and trust instructions for Windows, macOS, and Linux. No more fumbling with OpenSSL commands! 🚀  

---

## Features

- 🖋️ **Interactive Setup** – Answer simple questions to configure your certificates.
- 🌐 **Wildcard & Subdomain Support** – Generate certificates for `*.<domain>` or specific subdomains.
- 🖌️ **Colored Messages & Emojis** – Friendly visual feedback in terminal.
- ⏳ **Spinner Feedback** – Watch progress while keys, CSRs, and certificates are being generated.
- 📂 **Custom Output Path** – Save certificates anywhere, default is `/opt/certs`.
- 🧾 **Automatic Logging** – Full log saved next to certificates, includes trust instructions for all OS.
- 🔄 **Container Restart Support** – Automatically restarts your Nginx/Traefik container.
- 📅 **Custom Expiry** – Set certificate validity (default 365 days).
- ✅ **Summary Table** – Quick overview of generated certificates.
- 🖥️ **Cross-Platform Trust Instructions** – Windows, macOS, Linux, and Firefox guidance.

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
