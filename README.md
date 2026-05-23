# 🛡 Harmony — Blocker

[![Build Status](https://github.com/Beros0408/harmony/actions/workflows/ci.yml/badge.svg)](https://github.com/Beros0408/harmony/actions)
[![Licence MIT](https://img.shields.io/badge/licence-MIT-blue.svg)](LICENSE)
[![iOS](https://img.shields.io/badge/iOS-17%2B-lightgrey?logo=apple)](mobile/)
[![Android](https://img.shields.io/badge/Android-10%2B-green?logo=android)](mobile/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](mobile/)

> **Harmony** est une application mobile de filtrage d'appels intelligents, de contrôle parental avancé et de suivi fitness — conçue pour redonner le contrôle du numérique à ses utilisateurs.

---

## Architecture du monorepo

```
harmony/
├── mobile/                    # Application Flutter (iOS & Android)
├── backend/                   # API REST FastAPI + PostgreSQL + Redis
├── docs/
│   ├── architecture/          # Diagrammes C4, ADR (Architecture Decision Records)
│   ├── design-system/         # Spécifications UI/UX, tokens de design
│   └── api/                   # Documentation OpenAPI générée automatiquement
├── .github/
│   ├── workflows/             # Pipelines CI/CD GitHub Actions
│   ├── ISSUE_TEMPLATE/        # Templates d'issues (bug, feature)
│   └── PULL_REQUEST_TEMPLATE.md
├── scripts/                   # Scripts utilitaires (setup, déploiement)
├── .gitignore
├── .editorconfig
├── LICENSE
├── README.md
└── CONTRIBUTING.md
```

---

## Prérequis

| Outil         | Version minimale | Installation                                      |
|---------------|------------------|---------------------------------------------------|
| Flutter       | 3.x              | https://docs.flutter.dev/get-started/install      |
| Dart          | 3.x              | Inclus avec Flutter                               |
| Python        | 3.12             | https://www.python.org/downloads/                 |
| Docker        | 24+              | https://docs.docker.com/get-docker/               |
| PostgreSQL    | 16               | Via Docker (voir `backend/docker-compose.yml`)    |
| Redis         | 7                | Via Docker (voir `backend/docker-compose.yml`)    |

---

## Installation locale

### Application mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

### Backend (FastAPI)

```bash
cd backend
python -m venv .venv
source .venv/bin/activate        # Linux/macOS
# .venv\Scripts\activate         # Windows
pip install -r requirements.txt
docker-compose up -d             # Lance PostgreSQL et Redis
uvicorn app.main:app --reload
```

---

## Structure des sprints

Le développement suit une approche itérative documentée dans deux fichiers de suivi :

- [`Harmony_Iterations.md`](Harmony_Iterations.md) — Planning des sprints, objectifs et stories par itération
- [`Harmony_Progression.md`](Harmony_Progression.md) — Suivi de l'avancement réel sprint par sprint

Ces fichiers sont mis à jour à la **fin de chaque sprint** selon le processus décrit dans [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Stack technique

| Couche         | Technologie              | Rôle                                          |
|----------------|--------------------------|-----------------------------------------------|
| Mobile         | Flutter 3 / Dart 3       | Application iOS & Android native              |
| Gestion d'état | Riverpod / Bloc          | State management réactif                      |
| Backend API    | FastAPI (Python 3.12)    | API REST asynchrone                           |
| Base de données| PostgreSQL 16            | Données persistantes                          |
| Cache          | Redis 7                  | Sessions, files de tâches async               |
| ORM            | SQLAlchemy 2 + Alembic   | Modèles et migrations                         |
| Auth           | JWT + OAuth2             | Authentification et autorisation              |
| CI/CD          | GitHub Actions           | Tests, lint, déploiement automatisés          |
| Conteneurisation | Docker / Docker Compose| Environnement de développement reproductible  |

---

## Modules fonctionnels

- **Filtrage d'appels** — Blocage intelligent des appels spam et indésirables
- **Contrôle parental** — Gestion du temps d'écran, filtrage de contenu, suivi familial
- **Fitness** — Suivi d'activité physique, objectifs santé, notifications motivantes

---

## Licence

Ce projet est distribué sous licence [MIT](LICENSE).  
Copyright (c) 2026 Beros0408
