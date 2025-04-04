package main

import (
	"log"
	"net/http"

	"back/handlers"
	"back/middleware"
	"back/models"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func main() {
	// Initialisation de la base de données
	db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("Erreur connexion BDD:", err)
	}

	// Migration automatique des modèles
	err = db.AutoMigrate(&models.Individu{})
	if err != nil {
		log.Fatal("Erreur migration BDD:", err)
	}
	log.Println("Migration de la base de données terminée")

	// Initialisation des données de test
	InitDB()

	// Configuration des routes
	http.HandleFunc("/cni/create", middleware.CORS(handlers.HandleOCR(db)))

	// Démarrage du serveur
	log.Println("Serveur démarré sur http://localhost:8081")
	if err := http.ListenAndServe(":8081", nil); err != nil {
		log.Fatal("Erreur serveur:", err)
	}
}
