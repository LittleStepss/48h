package models

import "gorm.io/gorm"

type Individu struct {
	gorm.Model
	Nom           string `json:"nom"`
	Prenom        string `json:"prenom"`
	DateNaissance string `json:"date_naissance"`
	DateValidite  string `json:"date_validite"`
	NumeroCni     string `json:"numero_cni"`
	ClientID      uint   `json:"client_id"`
}
