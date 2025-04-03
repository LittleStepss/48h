-- Create tables if they don’t exist
CREATE TABLE IF NOT EXISTS clients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
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
    number TEXT NOT NULL,
    date_of_expiry TEXT NOT NULL,
    individus_id INTEGER,
    FOREIGN KEY (individus_id) REFERENCES individus(id)
);

CREATE TABLE IF NOT EXISTS collaborateurs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL,
    password TEXT NOT NULL
);

-- Creating Clients with enterprise names
INSERT INTO clients (name) VALUES ('Entreprise Alpha');
INSERT INTO clients (name) VALUES ('Entreprise Beta');
INSERT INTO clients (name) VALUES ('Entreprise Gamma');
INSERT INTO clients (name) VALUES ('Entreprise Delta');
INSERT INTO clients (name) VALUES ('Entreprise Epsilon');

-- Creating Users and associating them with Clients
-- Users for Entreprise Alpha
INSERT INTO individus (name, surname, client_id) VALUES ('IBRAHIM', 'Stanislas', 1);
INSERT INTO individus (name, surname, client_id) VALUES ('Jane', 'Doe', 1);

-- individus for Entreprise Beta
INSERT INTO individus (name, surname, client_id) VALUES ('David', 'Miller', 2);
INSERT INTO individus (name, surname, client_id) VALUES ('Eve', 'Davis', 2);

-- individus for Entreprise Gamma
INSERT INTO individus (name, surname, client_id) VALUES ('Ivy', 'Hernandez', 3);
INSERT INTO individus (name, surname, client_id) VALUES ('Jack', 'Lopez', 3);

-- individus for Entreprise Delta
INSERT INTO individus (name, surname, client_id) VALUES ('Nancy', 'Anderson', 4);
INSERT INTO individus (name, surname, client_id) VALUES ('Oscar', 'Thomas', 4);

-- individus for Entreprise Epsilon
INSERT INTO individus (name, surname, client_id) VALUES ('Sam', 'Clark', 5);
INSERT INTO individus (name, surname, client_id) VALUES ('Tina', 'Walker', 5);

INSERT INTO collaborateurs (email, password) VALUES ('didier.zozo@cerfrance.fr', 'rootroot');
