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
SOCKET_USER_SECRET=$(openssl rand -base64 32)
NEXTAUTH_SECRET=$(openssl rand -base64 32)
CRON_SECRET=$(openssl rand -base64 32)
success "INTERNAL_API_KEY généré"
success "SOCKET_USER_SECRET généré"
success "NEXTAUTH_SECRET généré"
success "CRON_SECRET généré"

# DATABASE_URL
ask "DATABASE_URL PostgreSQL (ex: postgresql://user:pass@host/db ?sslmode=verify-full est ajouté)"
read -r DATABASE_URL
while [[ -z "$DATABASE_URL" ]]; do
    warn "La DATABASE_URL est obligatoire."
    read -r DATABASE_URL
done
# Remplacer un sslmode existant ou ajouter sslmode=verify-full
DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/[?&]sslmode=[^&]*//')
if [[ "$DATABASE_URL" == *"?"* ]]; then
    DATABASE_URL="${DATABASE_URL}&sslmode=verify-full"
else
    DATABASE_URL="${DATABASE_URL}?sslmode=verify-full"
fi

# NEXTAUTH_URL
ask "URL publique de l'application (défaut: http://localhost:3000)"
read -r NEXTAUTH_URL
NEXTAUTH_URL="${NEXTAUTH_URL:-http://localhost:3000}"

# FRONTEND_URL pour les serveurs (sans trailing slash)
FRONTEND_URL="${NEXTAUTH_URL%/}"

# NODE_ENV
ask "NODE_ENV (défaut: development)"
read -r NODE_ENV
NODE_ENV="${NODE_ENV:-development}"

# Optionnels
echo ""
info "Variables optionnelles (laisser vide pour ignorer)"

ask "GROQ_API_KEY (pour la génération de quiz par IA)"
read -r GROQ_API_KEY

ask "GEMINI_KEY (pour la génération de quiz par IA)"
read -r GEMINI_KEY

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

ask "UNSPLASH_ACCESS_KEY (pour les images de couverture des quiz)"
read -r UNSPLASH_ACCESS_KEY
ask "UNSPLASH_SECRET_KEY"
read -r UNSPLASH_SECRET_KEY

ask "GMAIL_USER (adresse Gmail pour l'envoi d'emails)"
read -r GMAIL_USER
ask "GMAIL_CLIENT_ID (Google Cloud OAuth2 — pour l'envoi d'emails)"
read -r GMAIL_CLIENT_ID
ask "GMAIL_CLIENT_SECRET"
read -r GMAIL_CLIENT_SECRET
ask "GMAIL_REFRESH_TOKEN"
read -r GMAIL_REFRESH_TOKEN

ask "UPSTASH_REDIS_REST_URL (Redis Upstash — cache/rate limiting)"
read -r UPSTASH_REDIS_REST_URL
ask "UPSTASH_REDIS_REST_TOKEN"
read -r UPSTASH_REDIS_REST_TOKEN

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

# ─── Registre des serveurs de jeu — SOURCE UNIQUE DE VÉRITÉ ────────────────────
# Format : "dossier|port|var"
#   var → NEXT_PUBLIC_<var>_SERVER_URL  (dans le .env du frontend)
#       → <var>_SERVER_URL              (dans le .env du lobby)
# Ajouter un jeu = ajouter UNE ligne ici (clonage, .env, install et build suivent).
LOBBY_NAME="lobby-server"
LOBBY_PORT=10000
GAME_SERVERS=(
    "uno-server|10001|UNO"
    "quiz-server|10002|QUIZ"
    "taboo-server|10003|TABOO"
    "skyjow-server|10004|SKYJOW"
    "yahtzee-server|10005|YAHTZEE"
    "puissance4-server|10006|PUISSANCE4"
    "just-one-server|10007|JUSTONE"
    "battleship-server|10008|BATTLESHIP"
    "diamant-server|10009|DIAMANT"
    "impostor-server|10010|IMPOSTOR"
    "ludo-server|10011|LUDO"
    "perudo-server|10012|PERUDO"
    "cant-stop-server|10013|CANT_STOP"
    "mille-bornes-server|10014|MILLE_BORNES"
    "spyfall-server|10015|SPYFALL"
    "atlantide-server|10016|ATLANTIDE"
    "abalone-server|10017|ABALONE"
    "blokus-server|10018|BLOKUS"
    "sixquiprend-server|10019|SIX_QUI_PREND"
    "tanks-server|10020|TANKS"
    "complot-server|10021|COMPLOT"
    "dames-server|10022|DAMES"
)

clone_or_pull "$LOBBY_NAME" "$SCRIPT_DIR/$LOBBY_NAME"
for entry in "${GAME_SERVERS[@]}"; do
    IFS='|' read -r name _ _ <<< "$entry"
    clone_or_pull "$name" "$SCRIPT_DIR/$name"
done

success "Tous les dépôts sont prêts"

# ─── Écriture des .env ────────────────────────────────────────────────────────
header "Génération des fichiers .env"

# Listes d'URLs dérivées du registre (une seule source : GAME_SERVERS)
FRONT_URLS="NEXT_PUBLIC_LOBBY_SERVER_URL=\"http://localhost:${LOBBY_PORT}\""
LOBBY_URLS=""
for entry in "${GAME_SERVERS[@]}"; do
    IFS='|' read -r name port var <<< "$entry"
    FRONT_URLS+=$'\n'"NEXT_PUBLIC_${var}_SERVER_URL=\"http://localhost:${port}\""
    [[ -n "$LOBBY_URLS" ]] && LOBBY_URLS+=$'\n'
    LOBBY_URLS+="${var}_SERVER_URL=\"http://localhost:${port}\""
done

# .env Frontend (quiz)
cat > "$KWIZAR_DIR/.env" <<EOF
DATABASE_URL="${DATABASE_URL}"

NEXTAUTH_SECRET="${NEXTAUTH_SECRET}"
NEXTAUTH_URL="${NEXTAUTH_URL}"

NODE_ENV="${NODE_ENV}"

INTERNAL_API_KEY="${INTERNAL_API_KEY}"
SOCKET_USER_SECRET="${SOCKET_USER_SECRET}"

CRON_SECRET="${CRON_SECRET}"

GROQ_API_KEY="${GROQ_API_KEY}"
GEMINI_KEY="${GEMINI_KEY}"

DISCORD_CLIENT_ID="${DISCORD_CLIENT_ID}"
DISCORD_CLIENT_SECRET="${DISCORD_CLIENT_SECRET}"

GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID}"
GOOGLE_CLIENT_SECRET="${GOOGLE_CLIENT_SECRET}"

CLOUDINARY_CLOUD_NAME="${CLOUDINARY_CLOUD_NAME}"
CLOUDINARY_API_KEY="${CLOUDINARY_API_KEY}"
CLOUDINARY_API_SECRET="${CLOUDINARY_API_SECRET}"
UNSPLASH_ACCESS_KEY="${UNSPLASH_ACCESS_KEY}"
UNSPLASH_SECRET_KEY="${UNSPLASH_SECRET_KEY}"

GMAIL_USER="${GMAIL_USER}"
GMAIL_CLIENT_ID="${GMAIL_CLIENT_ID}"
GMAIL_CLIENT_SECRET="${GMAIL_CLIENT_SECRET}"
GMAIL_REFRESH_TOKEN="${GMAIL_REFRESH_TOKEN}"

UPSTASH_REDIS_REST_URL="${UPSTASH_REDIS_REST_URL}"
UPSTASH_REDIS_REST_TOKEN="${UPSTASH_REDIS_REST_TOKEN}"

${FRONT_URLS}

EOF
success ".env frontend (quiz)"

# .env serveurs de jeu (FRONTEND_URL + PORT + clés)
for entry in "${GAME_SERVERS[@]}"; do
    IFS='|' read -r server port _ <<< "$entry"
    cat > "$SCRIPT_DIR/$server/.env" <<EOF
FRONTEND_URL="${FRONTEND_URL}"
PORT=${port}
INTERNAL_API_KEY="${INTERNAL_API_KEY}"
SOCKET_USER_SECRET="${SOCKET_USER_SECRET}"
LOBBY_SERVER_URL="http://localhost:${LOBBY_PORT}"
EOF
    success ".env $server (port $port)"
done

# .env lobby (a besoin de toutes les URLs des serveurs)
cat > "$SCRIPT_DIR/lobby-server/.env" <<EOF
FRONTEND_URL="${FRONTEND_URL}"
PORT=10000
INTERNAL_API_KEY="${INTERNAL_API_KEY}"
SOCKET_USER_SECRET="${SOCKET_USER_SECRET}"

${LOBBY_URLS}
EOF
success ".env lobby-server (port 10000)"

# ─── Installation des dépendances ─────────────────────────────────────────────
header "Installation des dépendances npm"

install_deps() {
    local dir="$1"
    local name="$2"
    info "$name — npm ci"
    npm ci --prefix "$dir" --loglevel error
    success "$name"
}

install_deps "$SCRIPT_DIR" "dev-launcher (root)"

# Le package partagé doit être installé et buildé avant les serveurs qui en dépendent
install_deps "$SCRIPT_DIR/shared" "shared"
info "shared — build"
npm run build --prefix "$SCRIPT_DIR/shared" --loglevel error
success "shared (build)"

for entry in "${GAME_SERVERS[@]}"; do
    IFS='|' read -r server port _ <<< "$entry"
    install_deps "$SCRIPT_DIR/$server" "$server"
    info "$server — build"
    npm run build --prefix "$SCRIPT_DIR/$server" --loglevel error
    success "$server (build)"
done
install_deps "$SCRIPT_DIR/$LOBBY_NAME" "$LOBBY_NAME"
info "$LOBBY_NAME — build"
npm run build --prefix "$SCRIPT_DIR/$LOBBY_NAME" --loglevel error
success "$LOBBY_NAME (build)"
install_deps "$KWIZAR_DIR" "quiz (frontend)"

# ─── Base de données ──────────────────────────────────────────────────────────
header "Base de données"

info "Prisma generate + migrate deploy"

# Toujours générer AVANT (db push ne génère plus en v7)
(cd "$KWIZAR_DIR" && npx prisma generate)

MIGRATE_OUT=$(cd "$KWIZAR_DIR" && npx prisma migrate deploy 2>&1) && MIGRATE_OK=true || MIGRATE_OK=false

if $MIGRATE_OK; then
    success "Migrations appliquées"
else
    warn "migrate deploy échoué — synchronisation avec db push"
    (cd "$KWIZAR_DIR" && npx prisma db push --accept-data-loss)

    # Le schéma est maintenant synchronisé — marquer les migrations échouées/pending comme appliquées
    while IFS= read -r failed_migration; do
        [[ -z "$failed_migration" ]] && continue
        warn "Résolution de la migration : $failed_migration"
        (cd "$KWIZAR_DIR" && npx prisma migrate resolve --applied "$failed_migration") || true
    done < <(echo "$MIGRATE_OUT" | grep -oE '[0-9]{14}_[a-zA-Z0-9_]+')

    # Réessayer pour appliquer d'éventuelles migrations restantes
    (cd "$KWIZAR_DIR" && npx prisma migrate deploy) || \
        warn "Des migrations sont encore en attente — vérifier avec 'prisma migrate status'"

    success "Schéma synchronisé"
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
