#!/bin/bash

# ============================================================
#  git-pull-all.sh
#  Lance `git pull origin main` dans le dossier courant
#  et dans chacun de ses sous-dossiers git.
# ============================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SUCCESS=0
FAILED=0
SKIPPED=0

pull_repo() {
    local dir="$1"
    local name="$(basename "$dir")"

    if [ ! -d "$dir/.git" ]; then
        echo -e "${YELLOW}⏭  SKIP${NC}    $name  (pas un dépôt git)"
        ((SKIPPED++))
        return
    fi

    echo -e "${CYAN}⟳  PULL${NC}     $name"
    output=$(git -C "$dir" pull origin main 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        # Affiche "Already up to date." ou les fichiers mis à jour
        echo -e "${GREEN}✔  OK${NC}       $name — $(echo "$output" | tail -1)"
        ((SUCCESS++))
    else
        echo -e "${RED}✘  ERREUR${NC}   $name"
        echo "$output" | sed 's/^/            /'
        ((FAILED++))
    fi
}

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Git Pull All — $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${CYAN}  Racine : $ROOT_DIR${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 1. Dossier racine
pull_repo "$ROOT_DIR"

# 2. Sous-dossiers (niveau 1 uniquement)
for dir in "$ROOT_DIR"/*/; do
    [ -d "$dir" ] && pull_repo "${dir%/}"
done

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✔  Succès  : $SUCCESS${NC}"
echo -e "${YELLOW}⏭  Ignorés : $SKIPPED${NC}"
echo -e "${RED}✘  Erreurs : $FAILED${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

[ $FAILED -gt 0 ] && exit 1 || exit 0
