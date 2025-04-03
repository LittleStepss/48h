package main

import (
	"github.com/gin-gonic/gin"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"net/http"
	"os"
	"io/ioutil"
	"strings"
)

// Models
type Client struct {
	ID   uint   `json:"id" gorm:"primaryKey"`
	Name string `json:"name"`
}

type Individus struct {
	ID       uint   `json:"id" gorm:"primaryKey"`
	Name     string `json:"name"`
	Surname  string `json:"surname"`  // Add surname field
	ClientID uint   `json:"client_id"`
}

type CNI struct {
	ID       uint   `json:"id" gorm:"primaryKey"`
	Number  string `json:"number"`
	Date_of_expiry string `json:"date_of_expiry"`
	IndividusID uint   `json:"individus_id"`
}

type Collaborateurs struct {
	ID       uint   `json:"id" gorm:"primaryKey"`
	Email     string `json:"name"`
	Password  string `json:"surname"`
}

var db *gorm.DB

func initDB() {
	var err error
	db, err = gorm.Open(sqlite.Open("data/test.db"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	// Automatically migrate the schema
	db.AutoMigrate(&Client{}, &Individus{})

	// Load SQL file and execute
	filePath := "data/init.sql"
	if _, err := os.Stat(filePath); err == nil {
		content, err := ioutil.ReadFile(filePath)
		if err != nil {
			panic("failed to read init.sql")
		}
		commands := strings.Split(string(content), ";")
		for _, cmd := range commands {
			trimmedCmd := strings.TrimSpace(cmd)
			if trimmedCmd != "" {
				db.Exec(trimmedCmd)
			}
		}
	}
}

func getClients(c *gin.Context) {
	var clients []Client
	db.Find(&clients)

	c.JSON(http.StatusOK, gin.H{
		"message": "Success Retrieving clients",
		"code": 200,
		"data": clients,
	})
}

func getClient(c *gin.Context) {
	var client Client
	id := c.Param("id")

	if err := db.First(&client, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"message": "Client not found",
			"code": 404,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Success Retrieving the client",
		"code": 200,
		"data": client,
	})
}

func getIndividus(c *gin.Context) {
	var individus []Individus
	db.Find(&individus)

	c.JSON(http.StatusOK, gin.H{
		"message": "Success Retrieving the individus",
		"code": 200,
		"data": individus,
	})
}

func getIndividu(c *gin.Context) {
	var individu Individus
	id := c.Param("id")

	if err := db.First(&individu, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"message": "Individu not found",
			"code": 404,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Individu not found",
		"code": 200,
		"data": individu,
	})
}

func postlogin(c *gin.Context) {
	var request struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	// Bind JSON body to request struct
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Invalid request body",
			"code": 400,
		})
		return
	}

	// Check if email or password is empty
	if request.Email == "" || request.Password == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Email and password are required",
			"code": 400,
		})
		return
	}

	var collaborateur Collaborateurs

	// Find the collaborator by email
	if err := db.First(&collaborateur, "email = ?", request.Email).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusOK, gin.H{
				"message": "Invalid email or password",
				"code": 401,
			})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"message": "Internal server error",
				"code": 500,
			})
		}
		return
	}

	// Compare the provided password with the hashed password in the database
	if collaborateur.Password != request.Password {
		c.JSON(http.StatusOK, gin.H{
			"message": "Invalid email or password",
			"code": 401,
		})
		return
	}

	// If login is successful, respond with the collaborator data (or a token)
	c.JSON(http.StatusOK, gin.H{
		"message": "Login successful",
		"code": 200,
		"id": collaborateur.ID,
		"email": collaborateur.Email,
	})
}

func postCNI(c *gin.Context) {
	var cni CNI
	// Bind JSON data from the request body to the CNI struct
	if err := c.ShouldBindJSON(&cni); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Invalid request data",
			"code": 400,
		})
		return
	}

	// Check if the Individus with the given ID exists
	var individu Individus
	if err := db.First(&individu, cni.IndividusID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"message": "Individu not found",
			"code": 404,
		})
		return
	}

	// Create the new CNI entry in the database
	if err := db.Create(&cni).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "Internal server error",
			"code": 500,
		})
		return
	}

	// Respond with the created CNI
	c.JSON(http.StatusOK, gin.H{
		"code":    201,
		"message": "CNI created successfully",
		"cni":     cni.IndividusID,
	})
}

func getDoc(c *gin.Context) {
	// Open and read the API documentation JSON file
	content, err := ioutil.ReadFile("data/doc.json")
	if err != nil {

		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "Failed to load API documentation",
		})
		return
	}

	// Serve the API documentation as JSON response
	c.Data(http.StatusOK, "application/json", content)
}

func Error404(c *gin.Context) {
	c.JSON(http.StatusInternalServerError, gin.H{
		"code":    404,
		"message": "Road not found, documentation available at /api",
	})
	return
}
func main() {
	initDB()

	r := gin.Default()
	r.GET("/clients", getClients)
	r.GET("/clients/:id", getClient)
	r.GET("/individus", getIndividus)
	r.GET("/individus/:id", getIndividu)
	r.POST("/login", postlogin)
	r.POST("/cni/create", postCNI)
	r.GET("/api", getDoc)
	r.GET("/", Error404)

	r.Run(":8080")
}
