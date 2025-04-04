package services

import (
	"fmt"
	"os/exec"
	"regexp"
	"strings"
)

type OCRResult struct {
	Nom           string `json:"nom"`
	Prenom        string `json:"prenom"`
	DateNaissance string `json:"date_naissance"`
	DateValidite  string `json:"date_validite"`
	Numero        string `json:"numero"`
}

func ExtractTextFromImage(imagePath string) (*OCRResult, error) {
	cmd := exec.Command(
		"tesseract",
		imagePath,
		"stdout",
		"-l", "fra",
		"--dpi", "300",
		"--psm", "3",
		"--oem", "3",
	)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("erreur Tesseract: %v", err)
	}

	text := string(output)
	result := &OCRResult{}

	// Debug
	fmt.Printf("Texte extrait:\n%s\n", text)

	// Extraction du nom depuis la zone MRZ (plus fiable)
	if match := regexp.MustCompile(`IDFRA([A-Z]+)<<`).FindStringSubmatch(text); len(match) > 1 {
		result.Nom = strings.TrimRight(match[1], "<")
	}

	// Extraction du prénom depuis la zone MRZ
	if match := regexp.MustCompile(`\d{12}([A-Z]+)<+\d`).FindStringSubmatch(text); len(match) > 1 {
		result.Prenom = strings.TrimRight(match[1], "<")
	}

	// Extraction de la date de naissance (format: 21.01.1980)
	if match := regexp.MustCompile(`(\d{2})\.(\d{2})\.(\d{4})`).FindStringSubmatch(text); len(match) > 3 {
		result.DateNaissance = fmt.Sprintf("%s/%s/%s", match[1], match[2], match[3])
	}

	// Extraction du numéro depuis la zone MRZ (plus fiable)
	if match := regexp.MustCompile(`IDFRA[A-Z]+<+(\d{12})`).FindStringSubmatch(text); len(match) > 1 {
		result.Numero = match[1]
	}

	// Si les champs sont vides, essayer d'autres patterns
	if result.Nom == "" {
		if match := regexp.MustCompile(`Nom\s*:\s*([A-ZÀ-Ÿ]+(?:[\s-][A-ZÀ-Ÿ]+)*)`).FindStringSubmatch(text); len(match) > 1 {
			result.Nom = cleanField(match[1])
		}
	}

	if result.Prenom == "" {
		if match := regexp.MustCompile(`Prénom\s*:\s*([A-ZÀ-Ÿa-zà-ÿ]+(?:[\s-][A-ZÀ-Ÿa-zà-ÿ]+)*)`).FindStringSubmatch(text); len(match) > 1 {
			result.Prenom = cleanField(match[1])
		}
	}

	if result.DateNaissance == "" {
		if match := regexp.MustCompile(`Né\(e\)\s*le\s*:\s*(\d{2})[\./-](\d{2})[\./-](\d{4})`).FindStringSubmatch(text); len(match) > 3 {
			result.DateNaissance = fmt.Sprintf("%s/%s/%s", match[1], match[2], match[3])
		}
	}

	if result.Numero == "" {
		if match := regexp.MustCompile(`[DN]'IDENTITÉ\s*[No°]*\s*:?\s*[}\]]?\s*(\d{9,12})`).FindStringSubmatch(text); len(match) > 1 {
			result.Numero = cleanField(match[1])
		}
	}

	// Nettoyage final des valeurs
	result.Nom = cleanField(result.Nom)
	result.Prenom = cleanField(result.Prenom)
	result.DateNaissance = cleanField(result.DateNaissance)
	result.DateValidite = cleanField(result.DateValidite)
	result.Numero = cleanField(result.Numero)

	// Debug
	fmt.Printf("Résultat OCR:\n%+v\n", result)

	return result, nil
}

func cleanField(value string) string {
	if value == "" {
		return ""
	}

	// Supprime les caractères non désirés
	value = strings.TrimSpace(value)
	value = strings.ReplaceAll(value, "\r", "")
	value = strings.ReplaceAll(value, "\n", "")
	value = strings.ReplaceAll(value, "Néfe", "")
	value = strings.ReplaceAll(value, "AP", "")
	value = strings.ReplaceAll(value, "}", "")
	value = strings.ReplaceAll(value, "]", "")
	value = strings.ReplaceAll(value, "Néfe)", "")
	value = strings.ReplaceAll(value, "Né(e)", "")
	
	// Supprime les espaces multiples
	value = regexp.MustCompile(`\s+`).ReplaceAllString(value, " ")
	
	// Supprime les caractères spéciaux en début et fin
	value = strings.Trim(value, ".,;:!?\"'()[]{}<>\\/@#$%^&*_+=|~` ")

	// Convertit les caractères spéciaux
	value = strings.ReplaceAll(value, "Û", "U")
	value = strings.ReplaceAll(value, "Ï", "I")
	value = strings.ReplaceAll(value, "Ô", "O")
	value = strings.ReplaceAll(value, "É", "E")

	return value
}
