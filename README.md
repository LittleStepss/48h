# Scanner CNI Cerfrance

Application mobile développée pour Cerfrance Vendée permettant la numérisation et l'extraction automatique des informations des cartes d'identité.

## Fonctionnalités

- 🔐 Authentification sécurisée des utilisateurs
- 👥 Gestion des clients et des individus
- 📸 Capture de carte d'identité avec l'appareil photo
- 🔍 Extraction automatique des informations (OCR) :
  - Nom
  - Prénom
  - Date de naissance
  - Date de validité
  - Numéro de CNI (MRZ)
- ✅ Vérification et correction manuelle des données extraites
- 🔒 Transmission sécurisée des données

## Prérequis

### Frontend (Flutter)
- Flutter SDK (version 3.7.2 ou supérieure)
- Android Studio / VS Code
- Un appareil Android (physique ou émulateur)

### Backend (Go)
- Go 1.21 ou supérieur
- Tesseract OCR avec le pack français
  - Windows : `choco install tesseract`
  - Linux : `apt-get install tesseract-ocr tesseract-ocr-fra`
  - macOS : `brew install tesseract`
- PostgreSQL 15 ou supérieur

## Installation

1. Cloner le projet :
```bash
git clone [URL_DU_REPO]
cd [NOM_DU_REPO]
```

2. Configuration du backend :
```bash
cd back
go mod tidy
cp .env.example .env
# Éditer le fichier .env avec vos paramètres
```

3. Configuration du frontend :
```bash
cd front
flutter pub get
# Configurer l'URL de l'API dans lib/config/api_config.dart
```

## Démarrage

1. Lancer le backend :
```bash
cd back
go run .
```

2. Lancer le frontend :
```bash
cd front
flutter run
```

## Structure du projet

### Frontend
```
front/
├── lib/
│   ├── config/        # Configuration (API, etc.)
│   ├── models/        # Modèles de données
│   ├── screens/       # Écrans de l'application
│   ├── services/      # Services (API, OCR, etc.)
│   └── widgets/       # Widgets réutilisables
└── test/             # Tests unitaires et d'intégration
```

### Backend
```
back/
├── handlers/         # Gestionnaires d'API
├── middleware/       # Middleware (auth, CORS, etc.)
├── models/          # Modèles de données
├── services/        # Services (OCR, etc.)
└── main.go          # Point d'entrée
```

## Sécurité

- 🔐 Authentification JWT
- 🔒 HTTPS obligatoire en production
- 🛡️ Protection CORS configurée
- 📝 Validation des entrées
- 🗑️ Nettoyage automatique des fichiers temporaires
- 🔍 Logs détaillés pour l'audit

## API Documentation

La documentation de l'API est disponible aux endpoints suivants :
- `/swagger/index.html` : Documentation interactive
- `/swagger/doc.json` : Spécification OpenAPI

## Tests

### Frontend
```bash
cd front
flutter test
```

### Backend
```bash
cd back
go test ./...
```

## Contribution

1. Fork du projet
2. Création d'une branche (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit des changements (`git commit -m 'Ajout nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Création d'une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Support

Pour toute question ou problème :
1. Consulter la documentation
2. Vérifier les issues existantes
3. Créer une nouvelle issue si nécessaire

## Auteurs

- Équipe Cerfrance Vendée
- Contributeurs externes

## Description

Cette application permet aux employés de Cerfrance Vendée de simplifier le processus de numérisation des cartes d'identité de leurs clients. Elle offre les fonctionnalités suivantes :

- Authentification sécurisée
- Sélection des clients
- Sélection des individus
- Scan de carte d'identité avec OCR
- Vérification et correction des informations extraites
- Envoi sécurisé des données

## Architecture

### Frontend (Flutter)
- `lib/screens/` : Écrans de l'application
- `lib/services/` : Services pour l'authentification, l'API et le scan
- `lib/config/` : Configuration de l'application
- `lib/models/` : Modèles de données

### Backend (Go)
- `backend/main.go` : Point d'entrée du serveur
- `backend/handlers/` : Gestionnaires d'API
- `backend/models/` : Modèles de données
- `backend/middleware/` : Middleware (authentification, etc.)

## Sécurité

L'application implémente plusieurs mesures de sécurité :

- Stockage sécurisé des tokens d'authentification
- Chiffrement des données sensibles
- Validation des entrées utilisateur
- Gestion sécurisée des images
- Protection contre les attaques CSRF

## Documentation API

L'API est documentée avec OpenAPI. Consultez la documentation complète dans le dossier `docs/api`.

## Contribution

1. Forkez le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Pushez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Contact

Pour toute question ou suggestion, contactez l'équipe de développement.

cd front 
flutter pub get pour recuperer les dependances 
flutter run pour lance le projet

## Rappel de la demande :

L'objectif idéal est de développer une application mobile pour le compte de Cerfrance Vendée, permettant de :  

Sélectionner un client dans une liste de clients (à récupérer via un appel API)
Sélectionner une personne physique présente dans ce dossier client (à récupérer via un appel API)
Prendre en photo sa carte d'identité (CNI), 
Idéalement, la détourer, remettre à plat, etc., 
Appeler une API pour venir passer en paramètre :
La scan retouché de la carte d'identité
Les informations océrisées de la CNI.
Les informations indispensables à récupérer sur la CNI sont les suivantes :
Nom
Prénom
Date de naissance
Date de fin de validité de la CNI
Numéro de la CNI.
Voici la cinématique de l'application mobile :

![image](https://github.com/user-attachments/assets/bafb3366-40e6-447f-a20b-f4d113a568a2)

Les APIs Cerfrance Vendée existent déjà et se chargent de fournir la liste des clients, des individus composant un client, et l'enregistrement des informations en base. Dans le cadre de ce challenge, vous pourrez mettre en place un back-end pour simuler ces APIs.

Afin de rester cohérent, vous devrez néanmoins vous assurer de la sécurité de ce back-end en termes de stockage, d'accès, et assurer la sécurité des transferts de données du client au back-end.

Pour ce back-end, le modèle de données est très simple :

![image](https://github.com/user-attachments/assets/6b0a8ea8-ea6b-420d-8e8f-d3ae1df47c69)



Vous êtes libres de la forme du prototype, des technologies employées et de votre organisation générale pour aboutir à un prototype dans le temps imparti.

En revanche, vous devez partir du principe que le client sélectionnera votre projet pour une exploitation interne, et devra probablement y apporter des modifications : il est donc primordial que le projet soit bien documenté pour une remise au client (le code et l'API sont documentée avec ESDoc ou équivalent, et OpenAPI pour toute API web, et le code en lui-même est compréhensible et bien commenté). On attendra également un fichier Readme expliquant comment lancer le projet et toute information utile pour le comprendre et le prendre en main

Enfin, on attendra un guide expliquant les mesures qui ont été prises pour garantir la sécurité des données et des préconisations permettant de sécuriser le serveur où serait hébergé votre solution. Il ne devra pas dépasser 4 pages et rester synthétique. Il peut faire référence à des documents externes plus abouti, mais on n'attend pas de vous de tout ré-écrire par vous-mêmes.

## Schéma infrastructure de l'application :

![image](https://github.com/user-attachments/assets/8ed02b13-5399-46d3-bab0-aa79de4e9254)



