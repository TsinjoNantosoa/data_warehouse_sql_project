# Projet Data Warehouse et Analytics

Bienvenue dans le projet **Data Warehouse et Analytics** ! 🚀

Ce projet illustre une solution complète de data warehousing et d'analytique, depuis la conception du Data Warehouse jusqu'à la génération d'insights exploitables.

## 🏗️ Architecture des données

Le projet utilise une architecture de type Medallion avec trois couches :

1. **Bronze Layer** : Contient les données brutes extraites telles qu'elles sont fournies par les systèmes sources (CSV, ERP, CRM).

2. **Silver Layer** : Contient les données nettoyées, standardisées et transformées pour assurer la qualité et la cohérence.

3. **Gold Layer** : Contient les données prêtes pour l'analyse et le reporting, modélisées en star schema avec tables de faits et de dimensions.

## 📖 Vue d'ensemble du projet

Le projet inclut les étapes suivantes :

- **Architecture des données** : Conception d'un Data Warehouse moderne avec trois couches
- **ETL Pipelines** : Extraction, transformation et chargement des données
- **Modélisation des données** : Création des tables de faits et de dimensions 
- **Analytics & Reporting** : Génération de rapports SQL et dashboards

## 🎯 Compétences démontrées

- SQL et développement de requêtes analytiques
- Data Engineering et ETL
- Modélisation de données pour l'analyse  
- Reporting et analyse décisionnelle

## 🗂️ Catalogue des données – Gold Layer

### 1. gold.dim_customers
**Objectif** : Stocker les informations clients enrichies avec des données démographiques et géographiques.

| Nom de colonne | Type | Description |
|----------------|------|-------------|
| customer_key | INT | Clé substitutive unique identifiant chaque client |
| customer_id | INT | Identifiant unique attribué à chaque client |
| customer_number | NVARCHAR(50) | Code alphanumérique représentant le client |
| first_name | NVARCHAR(50) | Prénom du client |
| last_name | NVARCHAR(50) | Nom de famille du client |
| country | NVARCHAR(50) | Pays de résidence du client |
| marital_status | NVARCHAR(50) | Statut marital du client |
| gender | NVARCHAR(50) | Sexe du client |
| birthdate | DATE | Date de naissance du client |
| create_date | DATE | Date de création de l'enregistrement client |

### 2. gold.dim_products
**Objectif** : Fournir des informations sur les produits et leurs attributs.

| Nom de colonne | Type | Description |
|----------------|------|-------------|
| product_key | INT | Clé substitutive unique identifiant chaque produit |
| product_id | INT | Identifiant unique du produit |
| product_number | NVARCHAR(50) | Code alphanumérique du produit |
| product_name | NVARCHAR(50) | Nom descriptif du produit |
| category_id | NVARCHAR(50) | Identifiant unique de la catégorie |
| category | NVARCHAR(50) | Catégorie générale du produit |
| subcategory | NVARCHAR(50) | Sous-catégorie détaillée |
| maintenance_required | NVARCHAR(50) | Nécessité d'entretien (Oui/Non) |
| cost | INT | Prix ou coût du produit |
| product_line | NVARCHAR(50) | Ligne ou série du produit |
| start_date | DATE | Date de disponibilité |

### 3. gold.fact_sales 
**Objectif** : Stocker les données transactionnelles de ventes pour l'analyse.

| Nom de colonne | Type | Description |
|----------------|------|-------------|
| order_number | NVARCHAR(50) | Identifiant unique de commande |
| product_key | INT | Clé vers dim_products |
| customer_key | INT | Clé vers dim_customers |
| order_date | DATE | Date de la commande |
| shipping_date | DATE | Date d'expédition |
| due_date | DATE | Date limite de paiement |
| sales_amount | INT | Montant total de la vente |
| quantity | INT | Quantité commandée |
| price | INT | Prix unitaire |

## 📂 Structure du projet

```
├── datasets/       # Fichiers CSV sources (ERP et CRM)
├── docs/          # Documentation et catalogue
├── scripts/       # Scripts SQL pour ETL
├── tests/         # Tests et contrôle qualité  
├── README.md      # Présentation et catalogue
├── LICENSE        # Licence du projet
└── requirements.txt # Dépendances
```

## 🌐 Réseaux & Portfolio

Vous pouvez me retrouver et consulter mes projets sur les plateformes suivantes :

[![DataCamp](https://img.shields.io/badge/DataCamp-02B875?style=for-the-badge&logo=datacamp&logoColor=white)](https://www.datacamp.com/portfolio/sandaniainatsinjonantosoa)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/sandaniaina-tsinjo-nantosoa-b6209a330/)
[![Portfolio](https://img.shields.io/badge/Portfolio-000000?style=for-the-badge&logo=google-chrome&logoColor=white)](https://tsinjonanto.netlify.app/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/TsinjoNantosoa)
