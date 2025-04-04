package handlers

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"back/models"
	"back/services"

	"gorm.io/gorm"
)

type OCRRequest struct {
	IndividuID uint `json:"individu_id"`
}

type OCRResponse struct {
	Success bool       `json:"success"`
	Data    *OCRResult `json:"data,omitempty"`
	Error   string     `json:"error,omitempty"`
}

type OCRResult struct {
	Nom           string `json:"nom"`
	Prenom        string `json:"prenom"`
	DateNaissance string `json:"date_naissance"`
	DateValidite  string `json:"date_validite"`
	Numero        string `json:"numero"`
}

func HandleOCR(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Printf("=== Nouvelle requête OCR ===")
		log.Printf("Méthode: %s", r.Method)
		log.Printf("Headers: %+v", r.Header)

		// Configuration CORS
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Access-Control-Max-Age", "3600")

		// Gestion des requêtes OPTIONS
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		// Vérification de la méthode
		if r.Method != http.MethodPost {
			sendJSONError(w, "Méthode non autorisée", http.StatusMethodNotAllowed)
			return
		}

		// Vérification du type de contenu
		contentType := r.Header.Get("Content-Type")
		if !strings.Contains(contentType, "multipart/form-data") {
			log.Printf("Type de contenu invalide: %s", contentType)
			sendJSONError(w, "Type de contenu invalide", http.StatusBadRequest)
			return
		}

		// Parse du formulaire multipart
		err := r.ParseMultipartForm(32 << 20) // 32 MB
		if err != nil {
			log.Printf("Erreur parsing multipart: %v", err)
			sendJSONError(w, fmt.Sprintf("Erreur parsing formulaire: %v", err), http.StatusBadRequest)
			return
		}

		// Récupération de l'ID de l'individu
		individuIDStr := r.FormValue("individu_id")
		if individuIDStr == "" {
			sendJSONError(w, "ID de l'individu manquant", http.StatusBadRequest)
			return
		}

		individuID, err := strconv.ParseUint(individuIDStr, 10, 32)
		if err != nil {
			log.Printf("ID individu invalide: %v", err)
			sendJSONError(w, "ID de l'individu invalide", http.StatusBadRequest)
			return
		}

		// Vérification de l'existence de l'individu
		var individu models.Individu
		if err := db.First(&individu, individuID).Error; err != nil {
			log.Printf("Individu non trouvé: %v", err)
			sendJSONError(w, "Individu non trouvé", http.StatusNotFound)
			return
		}

		// Récupération du fichier
		file, header, err := r.FormFile("file")
		if err != nil {
			log.Printf("Erreur récupération fichier: %v", err)
			sendJSONError(w, "Erreur récupération fichier", http.StatusBadRequest)
			return
		}
		defer file.Close()

		log.Printf("Fichier reçu: %s (type: %s, taille: %d)",
			header.Filename,
			header.Header.Get("Content-Type"),
			header.Size)

		// Création du dossier temporaire
		tmpDir, err := os.MkdirTemp("", "ocr_*")
		if err != nil {
			log.Printf("Erreur création dossier temp: %v", err)
			sendJSONError(w, "Erreur système", http.StatusInternalServerError)
			return
		}
		defer os.RemoveAll(tmpDir)

		// Sauvegarde du fichier
		imagePath := filepath.Join(tmpDir, header.Filename)
		dst, err := os.Create(imagePath)
		if err != nil {
			log.Printf("Erreur création fichier: %v", err)
			sendJSONError(w, "Erreur système", http.StatusInternalServerError)
			return
		}
		defer dst.Close()

		if _, err := io.Copy(dst, file); err != nil {
			log.Printf("Erreur copie fichier: %v", err)
			sendJSONError(w, "Erreur système", http.StatusInternalServerError)
			return
		}

		// Extraction du texte
		log.Printf("Début extraction OCR...")
		result, err := services.ExtractTextFromImage(imagePath)
		if err != nil {
			log.Printf("Erreur OCR: %v", err)
			sendJSONError(w, fmt.Sprintf("Erreur OCR: %v", err), http.StatusInternalServerError)
			return
		}
		log.Printf("OCR terminé avec succès: %+v", result)

		// Mise à jour de l'individu
		updates := map[string]interface{}{
			"nom":            result.Nom,
			"prenom":         result.Prenom,
			"date_naissance": result.DateNaissance,
			"date_validite":  result.DateValidite,
			"numero_cni":     result.Numero,
		}

		if err := db.Model(&individu).Updates(updates).Error; err != nil {
			log.Printf("Erreur mise à jour BDD: %v", err)
			sendJSONError(w, "Erreur mise à jour données", http.StatusInternalServerError)
			return
		}

		// Envoi de la réponse
		response := OCRResponse{
			Success: true,
			Data: &OCRResult{
				Nom:           result.Nom,
				Prenom:        result.Prenom,
				DateNaissance: result.DateNaissance,
				DateValidite:  result.DateValidite,
				Numero:        result.Numero,
			},
		}

		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(response); err != nil {
			log.Printf("Erreur encodage réponse: %v", err)
			sendJSONError(w, "Erreur système", http.StatusInternalServerError)
			return
		}

		log.Printf("Requête OCR traitée avec succès")
	}
}

func sendJSONError(w http.ResponseWriter, message string, status int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	response := OCRResponse{
		Success: false,
		Error:   message,
	}
	json.NewEncoder(w).Encode(response)
}
