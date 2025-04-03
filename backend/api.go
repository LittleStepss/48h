package main

import (
  "github.com/gin-gonic/gin"
  "net/http"
  "strconv"
)

type Client struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type Individu struct {
	ID       int    `json:"id"`
	Name     string `json:"name"`
	Surname  string `json:"surname"`
	ClientID int    `json:"client_id"`
}

type InfosCNI struct {
  Nom           string `json:"nom"`
  Prenom        string `json:"prenom"`
  DateNaissance string `json:"dateNaissance"`
  NumeroCNI     string `json:"numeroCNI"`
  DateValidite  string `json:"dateValidite"`
}

type CNI struct {
  ClientID    string   `json:"clientId"`
  PersonneID  string   `json:"personneId"`
  ImageBase64 string   `json:"imageBase64"`
  DonneesCNI  InfosCNI `json:"donneesCNI"`
}

var clients = []Client{
	{ID: 1, Name: "Entreprise Alpha"},
	{ID: 2, Name: "Entreprise Beta"},
	{ID: 3, Name: "Entreprise Gamma"},
	{ID: 4, Name: "Entreprise Delta"},
	{ID: 5, Name: "Entreprise Epsilon"},
}

var individus = []Individu{
	{ID: 1, Name: "IBRAHIM", Surname: "Stanislas", ClientID: 1},
	{ID: 2, Name: "Jane", Surname: "Doe", ClientID: 1},
	{ID: 3, Name: "Alice", Surname: "Smith", ClientID: 1},
	{ID: 4, Name: "Bob", Surname: "Johnson", ClientID: 1},
	{ID: 5, Name: "Charlie", Surname: "Brown", ClientID: 1},
	{ID: 6, Name: "David", Surname: "Miller", ClientID: 2},
}

var cnis []CNI

// === Routes ===

func RegisterRoutes(r *gin.Engine) {
	r.GET("/clients", getClients)
	r.GET("/clients/:id/personnes", getPersonnes)
	r.GET("/individus", getAllIndividus)
	r.POST("/individus", postIndividu)
	r.POST("/upload-cni", postCNI)
}

// Handlers

func getClients(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"data":    clients,
		"message": "Success Retrieving clients",
	})
}

func getAllIndividus(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"data":    individus,
		"message": "Success Retrieving the individus",
	})
}

func getPersonnes(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID invalide"})
		return
	}

	var resultat []Individu
	for _, i := range individus {
		if i.ClientID == id {
			resultat = append(resultat, i)
		}
	}

	if len(resultat) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"message": "Aucune personne trouvée"})
		return
	}

	c.JSON(http.StatusOK, resultat)
}

func postIndividu(c *gin.Context) {
	var newIndividu Individu
	if err := c.ShouldBindJSON(&newIndividu); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	individus = append(individus, newIndividu)
	c.JSON(http.StatusOK, gin.H{"message": "Individu ajouté", "personne": newIndividu})
}

func postCNI(c *gin.Context) {
	var newCNI CNI
	if err := c.ShouldBindJSON(&newCNI); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	cnis = append(cnis, newCNI)
	c.JSON(http.StatusOK, gin.H{"message": "CNI reçue", "donnees": newCNI})
}