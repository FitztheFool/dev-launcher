# Dockerfile générique — fonctionne pour le lobby ET tous les serveurs de jeu
# (même structure partout : TypeScript dans src/ -> dist/, lancé via node dist/index.js).
# docker-compose.yml l'utilise avec un "context" différent par serveur.

# ─── Étape 1 : build TypeScript ───────────────────────────────────────────────
FROM node:22-alpine AS build
WORKDIR /app

# Dépendances (dev incluses : typescript, @types, etc.)
COPY package.json package-lock.json ./
RUN npm ci

# Code source + config, puis compilation -> dist/
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# ─── Étape 2 : image finale (runtime uniquement) ──────────────────────────────
FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production

# Dépendances de production seulement (plus léger)
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Build compilé récupéré depuis l'étape précédente
COPY --from=build /app/dist ./dist

# Le port réel est fourni par la variable PORT (définie dans docker-compose.yml).
CMD ["node", "dist/index.js"]
