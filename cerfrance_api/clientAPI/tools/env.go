package tools

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
)

func LoadEnv() string {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("❌ Error loading .env file")
	}
	fmt.Println("✅ .env file loaded")

	// Exemple : accès à une variable
	token := os.Getenv("AUTH_TOKEN")
	return token
}
