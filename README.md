

| Server                                                               | Port       |
| ---------------------------------------------------------------------|:----------:|
| [Front](https://github.com/FitztheFool/quiz)                         | 3000       |
| [Lobby](https://github.com/FitztheFool/lobby-server)                 | 10 000     |
| [Uno](https://github.com/FitztheFool/uno-server)                     | 10 001     |
| [Quiz](https://github.com/FitztheFool/quiz-server)                   | 10 002     |
| [Taboo](https://github.com/FitztheFool/taboo-server)                 | 10 003     |
| [Skyjow](https://github.com/FitztheFool/skijow-server)               | 10 004     |
| [Yahtzee](https://github.com/FitztheFool/yahtzee-server)             | 10 005     |
| [Puissance 4](https://github.com/FitztheFool/puissance4-server)      | 10 006     |
| [Just One](https://github.com/FitztheFool/just-one-server)           | 10 007     |
| [Bataille Navale](https://github.com/FitztheFool/battleship-server)  | 10 008     |
| [Diamant](https://github.com/FitztheFool/diamant-server)             | 10 009     |
| [Imposteur](https://github.com/FitztheFool/impostor-server)          | 10 010     |
| [Ludo](https://github.com/FitztheFool/ludo-server)                   | 10 011     |
| [Perudo](https://github.com/FitztheFool/perudo-server)               | 10 012     |
| [Can't Stop](https://github.com/FitztheFool/cant-stop-server)        | 10 013     |
| [Mille Bornes](https://github.com/FitztheFool/mille-bornes-server)   | 10 014     |
| [Spyfall](https://github.com/FitztheFool/spyfall-server)             | 10 015     |
| [Atlantide](https://github.com/FitztheFool/atlantide-server)         | 10 016     |
| [Abalone](https://github.com/FitztheFool/abalone-server)             | 10 017     |
| [Blokus](https://github.com/FitztheFool/blokus-server)               | 10 018     |
| [Six qui prend](https://github.com/FitztheFool/sixquiprend-server)   | 10 019     |
| [Tanks](https://github.com/FitztheFool/tanks-server)                 | 10 020     |
| [Complot](https://github.com/FitztheFool/complot-server)             | 10 021     |
| [Dames](https://github.com/FitztheFool/dames-server)                 | 10 022     |
| [Backgammon](https://github.com/FitztheFool/backgammon-server)       | 10 023     |


---

`install.sh` va tout installer, créer les .env et installer les nodes_modules. Permet aussi de tout mettre à jour.

---

Questions de l'installeur : 

- `URL db postgresql` : `postgresql://neondb_owner:xxxx@xxx/neondb?sslmode=verify-full`
- `URL du front` : défaut `http://localhost:3000`
- `NODE_ENV` : défaut `development`
- `GROQ_API_KEY` (facultatif) : pour générer des quizzes
- `GEMINI_KEY` (facultatif) : pour générer des quizzes
- `DISCORD_CLIENT_ID` et `DISCORD_CLIENT_SECRET` : oAuth avec discord
- `GOOGLE_CLIENT_ID` et `GOOGLE_CLIENT_SECRET` : oAuth avec google
- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET` : gestion des images 
- `UNSPLASH_ACCESS_KEY`, `UNSPLASH_SECRET_KEY` : gestion des images de couverture des quizzes
- `GMAIL_USER`, `GMAIL_CLIENT_ID`, `GMAIL_CLIENT_SECRET`, `GMAIL_REFRESH_TOKEN` : envoie de mail 
- Proposition de seed avec des données de test

---

Hébergerment du front :
- vercel

Hébergement de la db :
- neon

Hébergement des serveurs de jeu :
- render

Lancement des crons :
- console.cron-job
