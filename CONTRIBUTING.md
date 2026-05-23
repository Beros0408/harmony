# Guide de contribution — Harmony

Merci de contribuer au projet Harmony ! Ce document explique les règles et processus à suivre pour maintenir un code de qualité et une collaboration fluide.

---

## Table des matières

1. [Workflow Git](#workflow-git)
2. [Conventions de commits](#conventions-de-commits)
3. [Processus de Pull Request](#processus-de-pull-request)
4. [Exécution des tests](#exécution-des-tests)
5. [Fin de sprint — mise à jour des fichiers de suivi](#fin-de-sprint)

---

## Workflow Git

Nous utilisons un workflow basé sur des branches courtes et des PRs régulières.

### Branches principales

| Branche   | Rôle                                                          |
|-----------|---------------------------------------------------------------|
| `main`    | Code de production — toujours stable et déployable            |
| `develop` | Branche d'intégration — les features fusionnent ici           |

### Branches de travail

Utilisez le préfixe correspondant au type de changement :

```
feature/US-XXX-description-courte     # Nouvelle fonctionnalité
fix/US-XXX-description-courte         # Correction de bug
hotfix/description-courte             # Correctif urgent en production
docs/description-courte               # Documentation uniquement
refactor/description-courte           # Refactorisation sans changement fonctionnel
chore/description-courte              # Tâche de maintenance (dépendances, config)
```

### Cycle de vie d'une branche

```bash
# 1. Créer sa branche depuis develop
git checkout develop
git pull origin develop
git checkout -b feature/US-001-call-filtering

# 2. Travailler et commiter régulièrement
git add -p   # Ajouter les changements par morceaux (staging interactif)
git commit -m "feat(mobile): add call filtering screen"

# 3. Mettre à jour sa branche avant de pousser
git fetch origin
git rebase origin/develop

# 4. Pousser et ouvrir une PR
git push origin feature/US-001-call-filtering
```

---

## Conventions de commits

Nous suivons la spécification **[Conventional Commits](https://www.conventionalcommits.org/)**.

### Format

```
<type>(<portée>): <description courte en impératif>

[corps optionnel : explication du POURQUOI, pas du QUOI]

[pied de page optionnel : Refs, Breaking changes]
```

### Types acceptés

| Type       | Usage                                                        |
|------------|--------------------------------------------------------------|
| `feat`     | Nouvelle fonctionnalité                                       |
| `fix`      | Correction de bug                                             |
| `docs`     | Documentation uniquement                                      |
| `refactor` | Refactorisation (ni feature ni bug)                           |
| `test`     | Ajout ou correction de tests                                  |
| `chore`    | Maintenance, mise à jour de dépendances, configuration        |
| `perf`     | Amélioration des performances                                 |
| `ci`       | Changements dans les fichiers CI/CD                           |
| `style`    | Formatage, espaces (aucun changement de logique)              |

### Portées suggérées

`mobile`, `backend`, `auth`, `api`, `db`, `ui`, `docs`, `ci`, `deps`

### Exemples

```
feat(mobile): ajouter l'écran de filtrage d'appels

fix(backend): corriger la validation du token JWT expiré

docs: mettre à jour le README avec les prérequis Docker

refactor(api): extraire la logique de pagination dans un service dédié

test(backend): ajouter les tests d'intégration pour l'endpoint /calls

chore(deps): mettre à jour Flutter vers 3.24.0
```

### Règles

- Description en **minuscule**, sans point final
- Maximum **72 caractères** pour la première ligne
- Corps en français, expliquant le **pourquoi** du changement
- Référencer les user stories avec `Refs: US-XXX`
- Indiquer les breaking changes avec `BREAKING CHANGE:` dans le pied de page

---

## Processus de Pull Request

### Avant d'ouvrir une PR

- [ ] La branche est à jour avec `develop` (`git rebase origin/develop`)
- [ ] Tous les tests passent localement
- [ ] Le lint est propre (aucune erreur ni avertissement)
- [ ] La PR est de taille raisonnable (< 400 lignes modifiées de préférence)

### Ouverture de la PR

1. Utilisez le **[template de PR](.github/PULL_REQUEST_TEMPLATE.md)** — ne supprimez aucune section
2. Liez la PR aux issues correspondantes avec `Closes #XXX`
3. Assignez au moins un relecteur
4. Ajoutez les labels appropriés (`feature`, `bug`, `docs`, etc.)

### Revue de code

- Répondez à **tous les commentaires** avant de demander une nouvelle revue
- Marquez les discussions résolues avec ✅ après correction
- Évitez les force-push sur une branche en cours de revue — préférez de nouveaux commits

### Fusion

- La fusion est faite par le relecteur ayant approuvé la PR
- Stratégie : **Squash and merge** pour les features, **Merge commit** pour les hotfix
- Supprimez la branche après fusion

---

## Exécution des tests

### Tests mobile (Flutter)

```bash
cd mobile

# Tests unitaires
flutter test

# Tests avec couverture
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Analyse statique
flutter analyze

# Formatage
dart format --set-exit-if-changed .
```

### Tests backend (Python / FastAPI)

```bash
cd backend
source .venv/bin/activate

# Tests unitaires et d'intégration
pytest

# Tests avec couverture
pytest --cov=app --cov-report=html

# Vérification du typage statique
mypy app/

# Lint
ruff check app/
ruff format --check app/
```

---

## Fin de sprint

À la clôture de chaque sprint, les deux fichiers de suivi doivent être mis à jour **avant de fusionner dans `main`** :

### `Harmony_Iterations.md`

- Marquer les user stories terminées (✅)
- Déplacer les stories non terminées vers le sprint suivant avec justification
- Mettre à jour la vélocité réelle du sprint

### `Harmony_Progression.md`

- Ajouter une entrée pour le sprint clôturé :
  - Date de début et de fin réelles
  - Stories réalisées vs planifiées
  - Points marquants (blocages, décisions techniques, dettes techniques créées)
  - Métriques : couverture de tests, performance CI

### Processus

```bash
# 1. Mettre à jour les fichiers de suivi
git checkout develop
# ... éditer Harmony_Iterations.md et Harmony_Progression.md

git commit -m "docs: clôture Sprint X — mise à jour iterations et progression"

# 2. Fusionner dans main
git checkout main
git merge --no-ff develop -m "chore: release Sprint X"
git tag -a "sprint-X" -m "Sprint X completed"
git push origin main --tags
```
