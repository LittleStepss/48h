package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"golang.org/x/crypto/bcrypt"
	"bytes"
)

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

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// Structure pour la réponse de login
type LoginResponse struct {
	Token   string `json:"token"`
	Message string `json:"message"`
}

// structure d’un utilisateur simulé (comme une base)
type User struct {
	Username       string
	HashedPassword string
}

var users = []User{}

const baseURL = "http://foureight.gurvan-nicolas.fr:8080"

// Fonction générique pour récupérer des données via GET
func getData[T any](endpoint string) ([]T, error) {
	resp, err := http.Get(baseURL + endpoint)
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

func hashPassword(password string) (string, error) {
	hashed, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hashed), nil
}

func checkPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func registerUser(username, password string) error {
	hashedPassword, err := hashPassword(password)
	if err != nil {
		return err
	}
	users = append(users, User{Username: username, HashedPassword: hashedPassword})
	return nil
}

func loginViaAPI(username, password string) (string, error) {
	data := LoginRequest{Username: username, Password: password}
	jsonData, err := json.Marshal(data)
	if err != nil {
		return "", fmt.Errorf("erreur JSON: %w", err)
	}

	resp, err := http.Post(baseURL+"/login", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return "", fmt.Errorf("erreur POST: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("erreur lecture du corps: %w", err)
	}

	var loginResp LoginResponse
	if err := json.Unmarshal(body, &loginResp); err != nil {
		return "", fmt.Errorf("erreur parsing JSON: %w", err)
	}

	return loginResp.Token, nil
}


func loginLocal(username, password string) (string, error) {
	for _, user := range users {
		if user.Username == username {
			if checkPasswordHash(password, user.HashedPassword) {
				return "fake-jwt-token-123", nil
			}
			return "", fmt.Errorf("mot de passe invalide")
		}
	}
	return "", fmt.Errorf("utilisateur non trouvé")
}

func getAPIDoc() (string, error) {
	resp, err := http.Get(baseURL + "/api")
	if err != nil {
		return "", fmt.Errorf("erreur GET: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("erreur HTTP: %s", resp.Status)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("erreur lecture du corps: %w", err)
	}

	return string(body), nil
}

func main() {
	clients, err := getData[Client]("/clients")
	if err != nil {
		fmt.Println("Erreur récupération clients:", err)
	} else {
		fmt.Println("Clients:")
		for _, client := range clients {
			fmt.Printf("- ID: %d, Nom: %s\n", client.ID, client.Name)
		}
	}

	individus, err := getData[Individu]("/individus")
	if err != nil {
		fmt.Println("Erreur récupération individus:", err)
	} else {
		fmt.Println("Individus:")
		for _, individu := range individus {
			fmt.Printf("- ID: %d, Nom: %s %s, Client ID: %d\n", individu.ID, individu.Name, individu.Surname, individu.ClientID)
		}
	}

	username := "didier.zozo@cerfrance.fr"
	password := "rootroot"

	err = registerUser(username, password)
	if err != nil {
		fmt.Println("Erreur enregistrement utilisateur:", err)
		return
	}

	token, err := loginLocal(username, password) // ou loginViaAPI(username, password)
	if err != nil {
		fmt.Println("Erreur connexion:", err)
	} else {
		fmt.Println("Connexion réussie ! Token:", token)
	}
	// Récupération de la documentation API
	doc, err := getAPIDoc()
	if err != nil {
		fmt.Println("Erreur récupération API Doc:", err)
	} else {
		fmt.Println("Documentation API :\n", doc)
	}
}
