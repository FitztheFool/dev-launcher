#!/usr/bin/env bash
set -euo pipefail

# ─── Couleurs ────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}  ▸ $*${RESET}"; }
success() { echo -e "${GREEN}  ✔ $*${RESET}"; }
warn()    { echo -e "${YELLOW}  ⚠ $*${RESET}"; }
header()  { echo -e "\n${BOLD}${BLUE}══ $* ══${RESET}\n"; }
ask()     { echo -e "${YELLOW}  ? $*${RESET}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BOLD}${BLUE}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║      FitztheFool — Installation      ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${RESET}"

# ─── Vérification des prérequis ──────────────────────────────────────────────
header "Vérification des prérequis"

for cmd in git node npm openssl; do
    if command -v "$cmd" &>/dev/null; then
        if [[ "$cmd" == "openssl" ]]; then
            success "$cmd disponible ($(openssl version 2>&1 | head -1))"
        else
            success "$cmd disponible ($(command $cmd --version 2>&1 | head -1))"
        fi
    else
        echo -e "${RED}  ✖ $cmd introuvable — installe-le avant de continuer.${RESET}"
        exit 1
    fi
done

# ─── Variables d'environnement ────────────────────────────────────────────────
header "Configuration"

# Génération automatique
INTERNAL_API_KEY=$(openssl rand -base64 32)
NEXTAUTH_SECRET=$(openssl rand -base64 32)
CRON_SECRET=$(openssl rand -base64 32)
success "INTERNAL_API_KEY généré"
success "NEXTAUTH_SECRET généré"
success "CRON_SECRET généré"

# DATABASE_URL
ask "DATABASE_URL PostgreSQL (ex: postgresql://user:pass@host/db?sslmode=require)"
read -r DATABASE_URL
while [[ -z "$DATABASE_URL" ]]; do
    warn "La DATABASE_URL est obligatoire."
    read -r DATABASE_URL
done

# NEXTAUTH_URL
ask "URL publique de l'application (défaut: http://localhost:3000)"
read -r NEXTAUTH_URL
NEXTAUTH_URL="${NEXTAUTH_URL:-http://localhost:3000}"

# FRONTEND_URL pour les serveurs (sans trailing slash)
FRONTEND_URL="${NEXTAUTH_URL%/}"

# Optionnels
echo ""
info "Variables optionnelles (laisser vide pour ignorer)"

ask "GROQ_API_KEY (pour la génération de quiz par IA)"
read -r GROQ_API_KEY

ask "DISCORD_CLIENT_ID"
read -r DISCORD_CLIENT_ID
ask "DISCORD_CLIENT_SECRET"
read -r DISCORD_CLIENT_SECRET

ask "GOOGLE_CLIENT_ID"
read -r GOOGLE_CLIENT_ID
ask "GOOGLE_CLIENT_SECRET"
read -r GOOGLE_CLIENT_SECRET

ask "CLOUDINARY_CLOUD_NAME"
read -r CLOUDINARY_CLOUD_NAME
ask "CLOUDINARY_API_KEY"
read -r CLOUDINARY_API_KEY
ask "CLOUDINARY_API_SECRET"
read -r CLOUDINARY_API_SECRET

ask "GMAIL_USER (adresse Gmail pour l'envoi d'emails)"
read -r GMAIL_USER
ask "GMAIL_CLIENT_ID (Google Cloud OAuth2 — pour l'envoi d'emails)"
read -r GMAIL_CLIENT_ID
ask "GMAIL_CLIENT_SECRET"
read -r GMAIL_CLIENT_SECRET
ask "GMAIL_REFRESH_TOKEN"
read -r GMAIL_REFRESH_TOKEN

# ─── Clonage des dépôts ───────────────────────────────────────────────────────
header "Clonage des dépôts"

GITHUB="git@github.com:FitztheFool"

clone_or_pull() {
    local repo="$1"
    local dest="$2"
    if [[ -d "$dest/.git" ]]; then
        info "$dest déjà cloné — git pull"
        git -C "$dest" pull --ff-only 2>/dev/null || warn "Impossible de mettre à jour $dest"
    else
        info "Clonage de $repo → $dest"
        git clone "$GITHUB/$repo.git" "$dest"
    fi
}

# Frontend
clone_or_pull "kwizar" "$SCRIPT_DIR/../kwizar"
KWIZAR_DIR="$(cd "$SCRIPT_DIR/../kwizar" && pwd)"

# Package partagé
clone_or_pull "shared" "$SCRIPT_DIR/shared"

# Serveurs dans dev-launcher
declare -A SERVERS=(
    ["lobby-server"]="10000"
    ["uno-server"]="10001"
    ["quiz-server"]="10002"
    ["taboo-server"]="10003"
    ["skyjow-server"]="10004"
    ["yahtzee-server"]="10005"
    ["puissance4-server"]="10006"
    ["just-one-server"]="10007"
    ["battleship-server"]="10008"
    ["diamant-server"]="10009"
    ["impostor-server"]="10010"
)

for server in "${!SERVERS[@]}"; do
    clone_or_pull "$server" "$SCRIPT_DIR/$server"
done

success "Tous les dépôts sont prêts"

# ─── Écriture des .env ────────────────────────────────────────────────────────
header "Génération des fichiers .env"

# .env Frontend (quiz)
cat > "$KWIZAR_DIR/.env" <<EOF
DATABASE_URL="${DATABASE_URL}"

NEXTAUTH_SECRET="${NEXTAUTH_SECRET}"
NEXTAUTH_URL="${NEXTAUTH_URL}"

INTERNAL_API_KEY="${INTERNAL_API_KEY}"

CRON_SECRET="${CRON_SECRET}"

GROQ_API_KEY="${GROQ_API_KEY}"

DISCORD_CLIENT_ID="${DISCORD_CLIENT_ID}"
DISCORD_CLIENT_SECRET="${DISCORD_CLIENT_SECRET}"

GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID}"
GOOGLE_CLIENT_SECRET="${GOOGLE_CLIENT_SECRET}"

CLOUDINARY_CLOUD_NAME="${CLOUDINARY_CLOUD_NAME}"
CLOUDINARY_API_KEY="${CLOUDINARY_API_KEY}"
CLOUDINARY_API_SECRET="${CLOUDINARY_API_SECRET}"

GMAIL_USER="${GMAIL_USER}"
GMAIL_CLIENT_ID="${GMAIL_CLIENT_ID}"
GMAIL_CLIENT_SECRET="${GMAIL_CLIENT_SECRET}"
GMAIL_REFRESH_TOKEN="${GMAIL_REFRESH_TOKEN}"

NEXT_PUBLIC_LOBBY_SERVER_URL="http://localhost:10000"
NEXT_PUBLIC_UNO_SERVER_URL="http://localhost:10001"
NEXT_PUBLIC_QUIZ_SERVER_URL="http://localhost:10002"
NEXT_PUBLIC_TABOO_SERVER_URL="http://localhost:10003"
NEXT_PUBLIC_SKYJOW_SERVER_URL="http://localhost:10004"
NEXT_PUBLIC_YAHTZEE_SERVER_URL="http://localhost:10005"
NEXT_PUBLIC_P4_SERVER_URL="http://localhost:10006"
NEXT_PUBLIC_JUSTONE_SERVER_URL="http://localhost:10007"
NEXT_PUBLIC_BATTLESHIP_SERVER_URL="http://localhost:10008"
NEXT_PUBLIC_DIAMANT_SERVER_URL="http://localhost:10009"
NEXT_PUBLIC_IMPOSTOR_SERVER_URL="http://localhost:10010"

EOF
success ".env frontend (quiz)"

# .env serveurs classiques (FRONTEND_URL + PORT + INTERNAL_API_KEY)
SIMPLE_SERVERS=(
    "uno-server:10001"
    "quiz-server:10002"
    "taboo-server:10003"
    "skyjow-server:10004"
    "yahtzee-server:10005"
    "puissance4-server:10006"
    "just-one-server:10007"
    "battleship-server:10008"
    "diamant-server:10009"
    "impostor-server:10010"
)

for entry in "${SIMPLE_SERVERS[@]}"; do
    server="${entry%%:*}"
    port="${entry##*:}"
    cat > "$SCRIPT_DIR/$server/.env" <<EOF
FRONTEND_URL="${FRONTEND_URL}"
PORT=${port}
INTERNAL_API_KEY="${INTERNAL_API_KEY}"
LOBBY_SERVER_URL="http://localhost:10000"
EOF
    success ".env $server (port $port)"
done

# .env lobby (a besoin de toutes les URLs des serveurs)
cat > "$SCRIPT_DIR/lobby-server/.env" <<EOF
FRONTEND_URL="${FRONTEND_URL}"
PORT=10000
INTERNAL_API_KEY="${INTERNAL_API_KEY}"

UNO_SERVER_URL="http://localhost:10001"
QUIZ_SERVER_URL="http://localhost:10002"
TABOO_SERVER_URL="http://localhost:10003"
SKYJOW_SERVER_URL="http://localhost:10004"
YAHTZEE_SERVER_URL="http://localhost:10005"
PUISSANCE4_SERVER_URL="http://localhost:10006"
JUSTONE_SERVER_URL="http://localhost:10007"
BATTLESHIP_SERVER_URL="http://localhost:10008"
DIAMANT_SERVER_URL="http://localhost:10009"
IMPOSTOR_SERVER_URL="http://localhost:10010"
EOF
success ".env lobby-server (port 10000)"

# ─── Installation des dépendances ─────────────────────────────────────────────
header "Installation des dépendances npm"

install_deps() {
    local dir="$1"
    local name="$2"
    info "$name — npm install"
    npm install --prefix "$dir" --loglevel error
    success "$name"
}

install_deps "$SCRIPT_DIR" "dev-launcher (root)"

# Le package partagé doit être installé et buildé avant les serveurs qui en dépendent
install_deps "$SCRIPT_DIR/shared" "shared"
info "shared — build"
npm run build --prefix "$SCRIPT_DIR/shared" --loglevel error
success "shared (build)"

for entry in "${SIMPLE_SERVERS[@]}"; do
    server="${entry%%:*}"
    install_deps "$SCRIPT_DIR/$server" "$server"
done
install_deps "$SCRIPT_DIR/lobby-server" "lobby-server"
install_deps "$KWIZAR_DIR" "quiz (frontend)"

# ─── Base de données ──────────────────────────────────────────────────────────
header "Base de données"

info "Prisma generate + migrate deploy"

# Toujours générer AVANT (db push ne génère plus en v7)
(cd "$KWIZAR_DIR" && npx prisma generate)

if (cd "$KWIZAR_DIR" && npx prisma migrate deploy); then
    success "Migrations appliquées"
else
    warn "migrate deploy échoué — tentative avec db push"
    (cd "$KWIZAR_DIR" && npx prisma db push --accept-data-loss)
    success "Schéma synchronisé avec db push"
fi

ask "Lancer le seed de données de test ? (o/N)"
read -r DO_SEED
if [[ "${DO_SEED,,}" == "o" || "${DO_SEED,,}" == "oui" || "${DO_SEED,,}" == "y" ]]; then
    info "Seed en cours…"
    (cd "$KWIZAR_DIR" && npm run db:seed)
    success "Seed terminé"
fi

# ─── Résumé ───────────────────────────────────────────────────────────────────
header "Installation terminée"

echo -e "${BOLD}Pour démarrer :${RESET}"
echo ""
echo -e "  ${CYAN}# Terminal 1 — Serveurs de jeu${RESET}"
echo -e "  cd $(realpath "$SCRIPT_DIR") && npm run dev"
echo ""
echo -e "  ${CYAN}# Terminal 2 — Frontend${RESET}"
echo -e "  cd $KWIZAR_DIR && npm run dev"
echo ""
echo -e "  ${CYAN}# Puis ouvrir${RESET} ${BOLD}${NEXTAUTH_URL}${RESET}"
echo ""
echo -e "${GREEN}${BOLD}  ✔ Tout est prêt.${RESET}"
