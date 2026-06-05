CREATE TABLE IF NOT EXISTS copnet_persons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    dob DATE,
    wanted_level INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS copnet_vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plate VARCHAR(20),
    model VARCHAR(50),
    color VARCHAR(30),
    owner_id INT,
    FOREIGN KEY (owner_id) REFERENCES copnet_persons(id)
);

CREATE TABLE IF NOT EXISTS copnet_wanted (
    id INT AUTO_INCREMENT PRIMARY KEY,
    person_id INT,
    level INT DEFAULT 0,
    notes TEXT,
    updated_at DATETIME,
    FOREIGN KEY (person_id) REFERENCES copnet_persons(id)
);

CREATE TABLE IF NOT EXISTS copnet_dispatch (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    description TEXT,
    location VARCHAR(100),
    created_by INT,
    created_at DATETIME
);
-- Nutzer / Rollen
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('beamter','ermittler','admin') NOT NULL DEFAULT 'beamter',
    active TINYINT(1) DEFAULT 1
);

-- Personen
CREATE TABLE persons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    geburtsdatum DATE,
    adresse VARCHAR(255),
    bemerkung TEXT
);

-- Fahrzeuge
CREATE TABLE vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plate VARCHAR(20) NOT NULL UNIQUE,
    model VARCHAR(100),
    color VARCHAR(50),
    owner_id INT,
    FOREIGN KEY (owner_id) REFERENCES persons(id)
);

-- Fälle (inkl. interne Ermittlung)
CREATE TABLE cases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    type ENUM('strafsache','interne_ermittlung') NOT NULL,
    status ENUM('offen','in_bearbeitung','abgeschlossen') NOT NULL DEFAULT 'offen',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Fall-Logs / Notizen
CREATE TABLE case_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT NOT NULL,
    author_id INT NOT NULL,
    note TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES cases(id),
    FOREIGN KEY (author_id) REFERENCES users(id)
);

-- Admin-Logs (z.B. Rechteänderungen)
CREATE TABLE admin_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    action VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id)
);
-- Nutzer / Rollen
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('beamter','ermittler','admin') NOT NULL DEFAULT 'beamter',
    active TINYINT(1) DEFAULT 1
);

-- Beispiel-Admin
INSERT INTO users (username, password_hash, role, active)
VALUES (
    'admin',
    '$2y$10$abcdefghijklmnopqrstuv1234567890abcdefghi', -- Platzhalter
    'admin',
    1
);

-- Personen
CREATE TABLE persons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    geburtsdatum DATE,
    adresse VARCHAR(255),
    bemerkung TEXT
);

-- Fahrzeuge
CREATE TABLE vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plate VARCHAR(20) NOT NULL UNIQUE,
    model VARCHAR(100),
    color VARCHAR(50),
    owner_id INT,
    FOREIGN KEY (owner_id) REFERENCES persons(id)
);

-- Fälle (inkl. interne Ermittlung)
CREATE TABLE cases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    type ENUM('strafsache','interne_ermittlung') NOT NULL,
    status ENUM('offen','in_bearbeitung','abgeschlossen') NOT NULL DEFAULT 'offen',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Fall-Logs / Notizen
CREATE TABLE case_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT NOT NULL,
    author_id INT NOT NULL,
    note TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES cases(id),
    FOREIGN KEY (author_id) REFERENCES users(id)
);

-- Admin-Logs
CREATE TABLE admin_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    action VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id)
);
-- WANTED SYSTEM
CREATE TABLE wanted (
    id INT AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    reason TEXT NOT NULL,
    level ENUM('niedrig','mittel','hoch','sehr_hoch') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    FOREIGN KEY (person_id) REFERENCES persons(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- DISPATCH / LEITSTELLE
CREATE TABLE dispatch_calls (
    id INT AUTO_INCREMENT PRIMARY KEY,
    caller VARCHAR(100),
    location VARCHAR(255),
    description TEXT,
    status ENUM('offen','zugewiesen','erledigt') DEFAULT 'offen',
    assigned_to INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES users(id)
);

-- DIENSTSYSTEM
CREATE TABLE duty (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    on_duty TINYINT(1) DEFAULT 0,
    last_change DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- BEWEISE
CREATE TABLE evidence (
    id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT NOT NULL,
    title VARCHAR(150),
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES cases(id)
);

-- FAHRZEUGHISTORIE
CREATE TABLE vehicle_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    action VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
);
