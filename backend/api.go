package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

// Structure pour les clients
type Client struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

// Structure pour les individus
type Individu struct {
	ID       int    `json:"id"`
	Name     string `json:"name"`
	Surname  string `json:"surname"`
	ClientID int    `json:"client_id"`
}

// Structure pour la réponse API générique
type APIResponse[T any] struct {
	Code    int    `json:"code"`
	Data    []T    `json:"data"`
	Message string `json:"message"`
}

const (
	baseURL = "http://foureight.gurvan-nicolas.fr:8080"
	// 🔹 Token d'authentification en dur
	authToken = "6UXrKe@zSKdnn7rUz#4A@NQ6CU#PYEgw4eRuK^*f"
)

// 🔹 Fonction GET avec AUTHENTIFICATION
func getDataWithAuth[T any](endpoint string) ([]T, error) {
	client := &http.Client{}
	req, err := http.NewRequest("GET", baseURL+endpoint, nil)
	if err != nil {
		return nil, fmt.Errorf("erreur création requête: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+authToken)

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("erreur GET: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("erreur HTTP: %s", resp.Status)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("erreur lecture du corps: %w", err)
	}

	var apiResp APIResponse[T]
	if err := json.Unmarshal(body, &apiResp); err != nil {
		return nil, fmt.Errorf("erreur parsing JSON: %w", err)
	}

	return apiResp.Data, nil
}

func main() {
	// 🔹 Récupération des clients (avec auth)
	clients, err := getDataWithAuth[Client]("/clients")
	if err != nil {
		fmt.Println("Erreur récupération clients:", err)
	} else {
		fmt.Println("Clients:")
		for _, client := range clients {
			fmt.Printf("- ID: %d, Nom: %s\n", client.ID, client.Name)
		}
	}

	// 🔹 Récupération des individus (avec auth)
	individus, err := getDataWithAuth[Individu]("/individus")
	if err != nil {
		fmt.Println("Erreur récupération individus:", err)
	} else {
		fmt.Println("Individus:")
		for _, individu := range individus {
			fmt.Printf("- ID: %d, Nom: %s %s, Client ID: %d\n", individu.ID, individu.Name, individu.Surname, individu.ClientID)
		}
	}
}
