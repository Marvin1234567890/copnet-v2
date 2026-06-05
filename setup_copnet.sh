#!/usr/bin/env bash
echo "🚔 COPNET V2 – Vollständiges System wird erstellt..."

# ================================
# Ordnerstruktur
# ================================
mkdir -p copnet-v2/{fivem/ui,sql,website,landing,login}

# ================================
# FiveM – fxmanifest
# ================================
cat > copnet-v2/fivem/fxmanifest.lua << 'EOF'
fx_version 'cerulean'
game 'gta5'

author 'Marvin'
description 'COPNET V2 – Polizei NRW System'
version '2.0.0'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js'
}

client_script 'client.lua'
server_script 'server.lua'
EOF

# ================================
# FiveM – client.lua
# ================================
cat > copnet-v2/fivem/client.lua << 'EOF'
RegisterCommand("copnet", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })
end)

RegisterNUICallback("close", function()
    SetNuiFocus(false, false)
end)
EOF

# ================================
# FiveM – server.lua
# ================================
cat > copnet-v2/fivem/server.lua << 'EOF'
print("[COPNET V2] Server gestartet – NRW Polizei System aktiv.")
EOF

# ================================
# FiveM – UI index.html
# ================================
cat > copnet-v2/fivem/ui/index.html << 'EOF'
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>COPNET V2 – Polizei NRW</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div id="tablet">
        <h1>COPNET V2 – Polizei NRW</h1>
        <button onclick="closeTablet()">Schließen</button>
    </div>
    <script src="app.js"></script>
</body>
</html>
EOF

# ================================
# FiveM – UI style.css
# ================================
cat > copnet-v2/fivem/ui/style.css << 'EOF'
body {
    margin: 0;
    background: rgba(0,0,0,0.7);
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
}
#tablet {
    width: 900px;
    height: 550px;
    background: #0a1a2a;
    color: white;
    border-radius: 20px;
    padding: 20px;
}
EOF

# ================================
# FiveM – UI app.js
# ================================
cat > copnet-v2/fivem/ui/app.js << 'EOF'
window.addEventListener("message", (event) => {
    if (event.data.action === "open") {
        document.body.style.display = "flex";
    }
});

function closeTablet() {
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
    document.body.style.display = "none";
}
EOF

# ================================
# SQL – schema.sql
# ================================
cat > copnet-v2/sql/schema.sql << 'EOF'
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
EOF

# ================================
# Website – index.html
# ================================
cat > copnet-v2/website/index.html << 'EOF'
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>COPNET V2 – NRW Polizei Tablet</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="themes.css">
</head>
<body>
    <div id="app"></div>
    <script src="app.js"></script>
</body>
</html>
EOF

# ================================
# Website – style.css
# ================================
cat > copnet-v2/website/style.css << 'EOF'
body {
    margin: 0;
    background: var(--bg);
    color: var(--text);
    font-family: system-ui;
}
EOF

# ================================
# Website – themes.css
# ================================
cat > copnet-v2/website/themes.css << 'EOF'
.theme-nrw { --bg:#0a1a2a; --text:#fff; }
.theme-glass { --bg:#e2ebf0; --text:#000; }
.theme-material { --bg:#f2f2f2; --text:#111; }
.theme-windows { --bg:#1f1f1f; --text:#fff; }
.theme-cyber { --bg:#02040a; --text:#0ff; }
EOF

# ================================
# Website – app.js
# ================================
cat > copnet-v2/website/app.js << 'EOF'
document.body.className = localStorage.getItem("copnet_theme") || "theme-nrw";
EOF

# ================================
# Landing Page
# ================================
cat > copnet-v2/landing/index.html << 'EOF'
<h1>🚔 COPNET V2 – Willkommen</h1>
<p>Modernes Polizei NRW System</p>
EOF

# ================================
# Login Page
# ================================
cat > copnet-v2/login/index.html << 'EOF'
<h1>🔐 COPNET Login</h1>
<p>Bitte PIN eingeben</p>
EOF

# ================================
# README.md
# ================================
cat > copnet-v2/README.md << 'EOF'
# 🚔 COPNET V2 – Polizei NRW System
Modernes Polizei-Tablet für FiveM & Web.
EOF

# ================================
# .gitignore
# ================================
cat > copnet-v2/.gitignore << 'EOF'
.my.cnf*
.mysql*
.my.output*
node_modules/
.vscode/
.idea/
.DS_Store
Thumbs.db
EOF

echo "✅ COPNET V2 – Komplettes System erfolgreich erstellt!"

