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
