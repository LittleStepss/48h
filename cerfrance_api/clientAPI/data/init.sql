-- Create tables if they don’t exist
CREATE TABLE IF NOT EXISTS clients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS individus (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    surname TEXT NOT NULL,
    client_id INTEGER,
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

CREATE TABLE IF NOT EXISTS cnis (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    number TEXT NOT NULL UNIQUE,
    date_of_expiry TEXT NOT NULL,
    individus_id INTEGER,
    FOREIGN KEY (individus_id) REFERENCES individus(id)
);

CREATE TABLE IF NOT EXISTS collaborateurs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL
);

-- Creating Clients with enterprise names if they do not already exist
INSERT INTO clients (name) 
SELECT 'Entreprise Alpha' WHERE NOT EXISTS (SELECT 1 FROM clients WHERE name = 'Entreprise Alpha');
INSERT INTO clients (name) 
SELECT 'Entreprise Beta' WHERE NOT EXISTS (SELECT 1 FROM clients WHERE name = 'Entreprise Beta');
INSERT INTO clients (name) 
SELECT 'Entreprise Gamma' WHERE NOT EXISTS (SELECT 1 FROM clients WHERE name = 'Entreprise Gamma');
INSERT INTO clients (name) 
SELECT 'Entreprise Delta' WHERE NOT EXISTS (SELECT 1 FROM clients WHERE name = 'Entreprise Delta');
INSERT INTO clients (name) 
SELECT 'Entreprise Epsilon' WHERE NOT EXISTS (SELECT 1 FROM clients WHERE name = 'Entreprise Epsilon');

-- Creating Users and associating them with Clients if they do not already exist
-- Users for Entreprise Alpha
INSERT INTO individus (name, surname, client_id) 
SELECT 'IBRAHIM', 'Stanislas', 1 WHERE NOT EXISTS (SELECT 1 FROM individus WHERE name = 'IBRAHIM' AND surname = 'Stanislas' AND client_id = 1);
INSERT INTO individus (name, surname, client_id) 
SELECT 'Jane', 'Doe', 1 WHERE NOT EXISTS (SELECT 1 FROM individus WHERE name = 'Jane' AND surname = 'Doe' AND client_id = 1);

-- Users for Entreprise Beta
INSERT INTO individus (name, surname, client_id) 
SELECT 'David', 'Miller', 2 WHERE NOT EXISTS (SELECT 1 FROM individus WHERE name = 'David' AND surname = 'Miller' AND client_id = 2);
INSERT INTO individus (name, surname, client_id) 
SELECT 'Eve', 'Davis', 2 WHERE NOT EXISTS (SELECT 1 FROM individus WHERE name = 'Eve' AND surname = 'Davis' AND client_id = 2);

-- Users for Entreprise Gamma
INSERT INTO individus (name, surname, client_id) 
SELECT 'Ivy', 'Hernandez', 3 WHERE NOT EXISTS (SELECT 1 FROM individus WHERE name = 'Ivy' AND surname = 'Hernandez' AND client_id = 3);
INSERT INTO individus (name, surname, client_id) 
SELECT 'Jack', 'Lopez', 3 WHERE NOT EXISTS (SELECT 1 FROM individus WHERE name = 'Jack' AND surname = 'Lopez' AND client_id = 3);

-- Users for Entreprise Delta
INSERT INTO individus (name, surname, client_id) 
SELECT 'Nancy', 'Anderson', 4 WHERE NOT EXISTS (SELECT 1 FROM individus WHERE name = 'Nancy' AND surname = 'Anderson' AND client_id = 4);
INSERT INTO individus (name, surname, client_id) 
SELECT 'Oscar', 'Thomas', 4 WHERE NOT EXISTS (SELECT 1 FROM individus WHERE name = 'Oscar' AND surname = 'Thomas' AND client_id = 4);

-- Users for Entreprise Epsilon
INSERT INTO individus (name, surname, client_id) 
SELECT 'Sam', 'Clark', 5 WHERE NOT EXISTS (SELECT 1 FROM individus WHERE name = 'Sam' AND surname = 'Clark' AND client_id = 5);
INSERT INTO individus (name, surname, client_id) 
SELECT 'Tina', 'Walker', 5 WHERE NOT EXISTS (SELECT 1 FROM individus WHERE name = 'Tina' AND surname = 'Walker' AND client_id = 5);

-- Creating Collaborateurs if they do not already exist
INSERT INTO collaborateurs (email, password) 
SELECT 'didier.zozo@cerfrance.fr', 'rootroot' WHERE NOT EXISTS (SELECT 1 FROM collaborateurs WHERE email = 'didier.zozo@cerfrance.fr');
