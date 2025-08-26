#!/bin/bash
# ==========================================
# Interactive Wildcard Certificate Generator
# ==========================================
# Author: Ilia-Shakeri
# Usage: chmod +x interactive.sh && ./interactive.sh
# ==========================================

clear

# ---------- COLORS ----------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'
PURPLE='\033[0;35m'
WHITE='\033[0;37m'
BOLD='\033[1m'

# ---------- FUNCTIONS ----------
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
separator() { echo -e "${BLUE}----------------------------------------${NC}"; }

spinner() {
    local pid=$1
    local msg=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    echo -ne "${CYAN}${msg}...${NC} "
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\b${spin:$i:1}"
        sleep 0.2
    done
    printf "\b${GREEN}✔ Done!${NC}\n"
}

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ---------- WELCOME ----------
echo -e "${PURPLE}=========================================${NC}"
echo -e "${PURPLE}🛠️  Welcome to the Interactive Wildcard Certificate Generator!${NC}"
echo -e "${PURPLE}-----------------------------------------${NC}"
echo -e "${WHITE}Hey! I'm Ilia-Shakeri, creator of this script.${NC}"
echo -e "${CYAN}GitHub: https://github.com/Ilia-Shakeri${NC}\n"
echo -e "${WHITE}This tool generates a local CA and wildcard SSL certificate"
echo -e "for your domain and optional subdomains, ready to use with Nginx/Traefik."
echo -e "You'll be guided through a few simple questions, defaults available."
echo -e "Let's secure your domains! 🚀${NC}"
echo -e "${PURPLE}=========================================${NC}\n"

# ---------- 1. Get Primary Domain ----------
while true; do
    separator
    read -rp "$(info 'Enter primary domain (e.g., test.com): ')" DOMAIN
    DOMAIN=$(echo "$DOMAIN" | tr -d ' ') # remove spaces

    if [[ -z "$DOMAIN" || ! "$DOMAIN" =~ \.[a-z]{2,}$ ]]; then
        warn "Invalid domain. Example: test.com"
    else
        break
    fi
done
SUBDOMAIN="*.$DOMAIN"
success "Primary domain set to $DOMAIN"
separator

# ---------- 2. Additional Subdomains ----------
read -rp "$(info "Enter additional subdomains (comma-separated, default is wildcard '*.$DOMAIN'): ")" SUBDOMAINS_INPUT

if [[ -z "$SUBDOMAINS_INPUT" ]]; then
    CERT_DOMAINS="*.$DOMAIN"
    echo -e "${GREEN}✅ Wildcard certificate will be created for: $CERT_DOMAINS${NC}"
else
    IFS=',' read -ra SUBS <<< "$SUBDOMAINS_INPUT"
    for i in "${!SUBS[@]}"; do
        SUBS[$i]="${SUBS[$i]// /}.$DOMAIN"
    done
    CERT_DOMAINS="${SUBS[*]}"
    DISPLAY_DOMAINS=$(echo "$CERT_DOMAINS" | sed 's/ /, /g')
    echo -e "${GREEN}✅ Certificate will be created for: $DISPLAY_DOMAINS${NC}"
fi
separator

# ---------- 3. Output Path ----------
read -rp "$(info "Enter certificate output path (default /opt/certs): ")" CERT_PATH
CERT_PATH=${CERT_PATH:-/opt/certs}
mkdir -p "$CERT_PATH"
LOG_FILE="$CERT_PATH/certs_$(date '+%Y%m%d_%H%M%S').log"
success "Certificates and log will be saved to $CERT_PATH"
separator

# ---------- 4. Nginx/Traefik Container ----------
read -rp "$(info "Enter Nginx/Traefik container name (default nginx-proxy): ")" CONTAINER_NAME
CONTAINER_NAME=${CONTAINER_NAME:-nginx-proxy}
success "Container set to $CONTAINER_NAME"
separator

# ---------- 5. Expiry ----------
read -rp "$(info "Enter certificate expiry in days (default 365): ")" EXPIRY_DAYS
EXPIRY_DAYS=${EXPIRY_DAYS:-365}
success "Certificate expiry set to $EXPIRY_DAYS days"
separator

# ---------- 6. Workdir ----------
WORKDIR="$HOME/local-ca"
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit
success "Working directory: $WORKDIR"
separator

# ---------- 7. Create CA ----------
info "Creating Local CA..."
openssl genpkey -algorithm RSA -out ca.key -pkeyopt rsa_keygen_bits:4096 &
spinner $! "Generating CA key"
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -subj "/CN=Local CA for $DOMAIN" -out ca.crt &
spinner $! "Generating CA certificate"
success "Local CA created."
separator

# ---------- 8. SAN config ----------
SAN="DNS:$SUBDOMAIN,DNS:$DOMAIN"
if [[ -n "$SUBDOMAINS_INPUT" ]]; then
    for sd in "${SUBS[@]}"; do
        SAN="$SAN,DNS:$sd"
    done
fi

cat > san.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[dn]
CN = $SUBDOMAIN

[req_ext]
subjectAltName = $SAN
EOF
success "SAN configuration created."
separator

# ---------- 9. Generate Key & CSR ----------
info "Generating wildcard key & CSR..."
openssl genpkey -algorithm RSA -out wildcard.key -pkeyopt rsa_keygen_bits:2048 &
spinner $! "Generating key"
openssl req -new -key wildcard.key -out wildcard.csr -config san.cnf &
spinner $! "Generating CSR"
success "Wildcard key and CSR generated."
separator

# ---------- 10. Sign CSR ----------
info "Signing certificate with local CA..."
openssl x509 -req -in wildcard.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out wildcard.crt -days "$EXPIRY_DAYS" -sha256 -extfile san.cnf -extensions req_ext &
spinner $! "Signing certificate"
success "Wildcard certificate signed."
separator

# ---------- 11. Fullchain ----------
info "Creating fullchain..."
cat wildcard.crt ca.crt > fullchain.pem &
spinner $! "Creating fullchain"
success "Fullchain created."
separator

# ---------- 12. Copy ----------
info "Copying certificates..."
sudo cp fullchain.pem "$CERT_PATH/cert.pem"
sudo cp wildcard.key "$CERT_PATH/key.pem"
sudo chmod 644 "$CERT_PATH/cert.pem"
sudo chmod 600 "$CERT_PATH/key.pem"
sudo chown root:root "$CERT_PATH/cert.pem" "$CERT_PATH/key.pem"
# log instructions
{
echo "Certificates:"
echo " - cert.pem"
echo " - key.pem"
echo " - CA: ca.crt"
echo ""
echo "To trust the CA:"
echo "Windows (Chrome/Edge): mmc -> Certificates -> Computer Account -> Trusted Root -> Import ca.crt"
echo "Firefox: Preferences -> Privacy & Security -> View Certificates -> Authorities -> Import ca.crt -> Check 'Trust for websites'"
echo "macOS: sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $CERT_PATH/ca.crt"
echo "Linux (Debian/Ubuntu): sudo cp $CERT_PATH/ca.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates"
} >> "$LOG_FILE"
success "Certificates copied. Log saved as $(basename $LOG_FILE)"
separator

# ---------- 13. Restart container ----------
info "Restarting container $CONTAINER_NAME..."
docker restart "$CONTAINER_NAME" &
spinner $! "Restarting container"
success "Container restarted."
separator

# ---------- 14. Summary ----------
separator
echo -e "${PURPLE}📋 Certificate Summary${NC}"
echo -e "${BLUE}----------------------------------------${NC}"
echo -e "${WHITE}Primary Domain   : ${DOMAIN}${NC}"
echo -e "${WHITE}Subdomains       : ${DISPLAY_DOMAINS:-$CERT_DOMAINS}${NC}"
echo -e "${WHITE}Expiry           : ${EXPIRY_DAYS} days${NC}"
echo -e "${WHITE}Output Path      : ${CERT_PATH}${NC}"
echo -e "${BLUE}----------------------------------------${NC}"
separator

# ---------- 15. Final Message ----------
echo -e "${GREEN}🎉 Certificate generation complete!${NC}"
echo -e "${CYAN}ℹ️  CA file: $WORKDIR/ca.crt${NC}"
echo -e "${CYAN}ℹ️  Log file with trust instructions saved next to certs: $LOG_FILE${NC}"
echo -e "${YELLOW}⭐ If you liked this tool, give it a star on my GitHub! https://github.com/Ilia-Shakeri${NC}"
separator
