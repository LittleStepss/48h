# Backend 


##  Préparation d'activation du backend

    1. Installer les packages golang

    
    go mod init backend
    go get github.com/joho/godotenv
    go mod tidy

    2. Crée un fichier .env avec le token de l'api cerfrance (un exemple)

    3. Lancer le programme avec la commande 'go run api.go' dans le repertoire BACKENDs