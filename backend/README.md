# Harmony Backend

Backend FastAPI (Python 3.12) pour l'application Harmony.  
Base de données PostgreSQL hébergée sur Supabase, connexion async via SQLAlchemy 2.0 + asyncpg.

## Prérequis

- Python 3.12+
- Accès à un projet Supabase (URL + clé secrète + mot de passe DB)

## Installation

### 1. Créer l'environnement virtuel

```bash
cd backend/
python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS / Linux
source .venv/bin/activate
```

### 2. Installer les dépendances

```bash
pip install -r requirements.txt
```

Ou avec `pyproject.toml` (inclut les dépendances de développement) :

```bash
pip install -e ".[dev]"
```

### 3. Configurer les variables d'environnement

```bash
cp .env.example .env
```

Ouvrir `.env` et renseigner :

| Variable | Description |
|---|---|
| `DATABASE_URL` | `postgresql+asyncpg://postgres:[MOT_DE_PASSE]@db.[PROJECT_ID].supabase.co:5432/postgres` |
| `SUPABASE_URL` | `https://[PROJECT_ID].supabase.co` |
| `SUPABASE_SECRET_KEY` | Clé secrète depuis Settings > API dans Supabase |
| `SECRET_KEY` | Générer avec `openssl rand -hex 32` |

### 4. Lancer le serveur

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

En production (workers multiples) :

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

## Vérifier que tout fonctionne

```bash
curl http://localhost:8000/
curl http://localhost:8000/health
```

Réponse attendue de `/health` si la base répond :

```json
{
  "status": "ok",
  "database": "connected",
  "env": "development"
}
```

## Documentation interactive

Activer `DEBUG=true` dans `.env`, puis ouvrir :

- Swagger UI : <http://localhost:8000/docs>
- ReDoc : <http://localhost:8000/redoc>

## Structure du projet

```
backend/
├── app/
│   ├── main.py          # Application FastAPI, /health, /
│   ├── core/
│   │   ├── config.py    # Settings (pydantic-settings, lecture .env)
│   │   ├── database.py  # Moteur async SQLAlchemy + health checks
│   │   ├── middleware.py # CORS, logging, sécurité, rate limiting
│   │   └── security.py  # JWT helpers
│   ├── api/v1/
│   │   └── auth/        # Routes d'authentification (prochaine étape)
│   ├── models/          # Modèles SQLAlchemy
│   └── schemas/         # Schémas Pydantic (entrées/sorties API)
├── alembic/             # Migrations de base de données
├── .env.example         # Modèle de configuration (sans secrets)
├── .gitignore
├── requirements.txt
└── pyproject.toml
```

## Commandes utiles

```bash
# Lancer les tests
pytest

# Créer une migration Alembic
alembic revision --autogenerate -m "description"

# Appliquer les migrations
alembic upgrade head
```
