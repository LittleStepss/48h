package main

import (
	"log"
	"back/models"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// InitDB initialise la base de données avec les données de test
func InitDB() {
	// Connexion à la base de données
	db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("Erreur connexion BDD:", err)
	}

	// Migration automatique
	err = db.AutoMigrate(&models.Individu{})
	if err != nil {
		log.Fatal("Erreur migration BDD:", err)
	}

	// Création d'un individu de test
	individu := models.Individu{
		Nom:           "Dupont",
		Prenom:        "Jean",
		DateNaissance: "01/01/1990",
		DateValidite:  "01/01/2030",
		NumeroCni:     "123456789",
		ClientID:      1,
	}

	// Vérification si l'individu existe déjà
	var count int64
	db.Model(&models.Individu{}).Where("id = ?", 1).Count(&count)
	if count == 0 {
		// Création de l'individu
		result := db.Create(&individu)
		if result.Error != nil {
			log.Fatal("Erreur création individu:", result.Error)
		}
		log.Println("Individu de test créé avec succès")
	} else {
		log.Println("Individu de test existe déjà")
	}
}
