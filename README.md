

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

---

`install.sh` va tout installer, créer les .env et installer les nodes_modules. Permet aussi de tout mettre à jour.

---

Questions de l'installeur : 

- URL db postgresql 
- URL du front, défaut `http://localhost:3000`
- `GROQ_API_KEY` (facultatif) : pour générer des quiz
- `DISCORD_CLIENT_ID` et `DISCORD_CLIENT_SECRET` : oAuth avec discord
- `GOOGLE_CLIENT_ID` et `GOOGLE_CLIENT_SECRET` : oAuth avec google
- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET` : gesstion des images 
- Proposition de seed avec des données de test

---

Hébergerment du front :
- vercel

Hébergement de la db :
- neon

Hébergement des serveurs de jeu :
- render
