CREATE TABLE IF NOT EXISTS copnet_persons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vorname VARCHAR(50),
    nachname VARCHAR(50),
    geburtsdatum DATE,
    adresse VARCHAR(100),
    telefon VARCHAR(20),
    dienststelle VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS copnet_wanted (
    id INT AUTO_INCREMENT PRIMARY KEY,
    person VARCHAR(100),
    reason VARCHAR(255),
    level VARCHAR(20),
    aktenzeichen VARCHAR(50)
);
