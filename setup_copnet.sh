
#!/usr/bin/env bash

# Ordnerstruktur
mkdir -p copnet-v2/html

# fxmanifest.lua
cat > copnet-v2/fxmanifest.lua << 'EOF'
fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

client_script 'client.lua'
server_script '@mysql-async/lib/MySQL.lua'
server_script 'server.lua'
EOF

# server.lua
cat > copnet-v2/server.lua << 'EOF'
-- COPNET V2 server.lua
-- Hier kommt der komplette COPNET-Code rein (MySQL, Wanted, Dispatch, etc.)
EOF

# client.lua
cat > copnet-v2/client.lua << 'EOF'
local open = false

RegisterCommand("copnet", function()
    open = not open
    SetNuiFocus(open, open)
    SendNUIMessage({ action = "toggle", state = open })
end)

RegisterNUICallback("close", function(data, cb)
    open = false
    SetNuiFocus(false, false)
    cb({})
end)
EOF

# index.html
cat > copnet-v2/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>COPNET V2</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div id="copnet">
        <div id="tabs">
            <button onclick="setTab('persons')">Personen</button>
            <button onclick="setTab('vehicles')">Fahrzeuge</button>
            <button onclick="setTab('wanted')">Wanted</button>
            <button onclick="setTab('dispatch')">Dispatch</button>
            <button onclick="setTab('duty')">Dienst</button>
            <button onclick="setTab('internal')">Interne Ermittlungen</button>
        </div>
        <div id="content"></div>
        <button id="close" onclick="closeNUI()">Schließen</button>
    </div>
    <script src="app.js"></script>
</body>
</html>
EOF

# style.css
cat > copnet-v2/html/style.css << 'EOF'
body {
    background: rgba(0,0,0,0.6);
    font-family: Arial, sans-serif;
}

#copnet {
    width: 900px;
    margin: 50px auto;
    background: #0a1a3a;
    padding: 20px;
    border-radius: 10px;
    color: white;
}

#tabs button {
    margin-right: 10px;
    padding: 10px;
    background: #123a7a;
    border: none;
    color: white;
    cursor: pointer;
}

#tabs button:hover {
    background: #1b4a9a;
}

.result {
    background: #102a5a;
    padding: 10px;
    margin-top: 10px;
    border-radius: 5px;
}
EOF

# app.js
cat > copnet-v2/html/app.js << 'EOF'
let currentTab = "persons";

window.addEventListener("message", function(e) {
    if (e.data.action === "toggle") {
        document.getElementById("copnet").style.display = e.data.state ? "block" : "none";
    }
});

function closeNUI() {
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

function setTab(tab) {
    currentTab = tab;
    renderTab();
}

function renderTab() {
    const c = document.getElementById("content");

    if (currentTab === "persons") {
        c.innerHTML = `
            <h2>Personenabfrage</h2>
            <input id="pquery" placeholder="Name...">
            <button onclick="searchPerson()">Suchen</button>
            <div id="results"></div>
        `;
    }

    if (currentTab === "vehicles") {
        c.innerHTML = `
            <h2>Fahrzeugabfrage</h2>
            <input id="plate" placeholder="Kennzeichen...">
            <button onclick="searchVehicle()">Suchen</button>
            <div id="results"></div>
        `;
    }

    if (currentTab === "wanted") {
        document.getElementById("content").innerHTML = `
            <h2>Wanted-Liste</h2>
            <div id="results"></div>
        `;
    }

    if (currentTab === "dispatch") {
        document.getElementById("content").innerHTML = `
            <h2>Dispatch</h2>
            <div id="results"></div>
        `;
    }

    if (currentTab === "duty") {
        document.getElementById("content").innerHTML = `
            <h2>Dienststatus</h2>
            <div id="results"></div>
        `;
    }

    if (currentTab === "internal") {
        document.getElementById("content").innerHTML = `
            <h2>Interne Ermittlungen</h2>
            <div id="results"></div>
        `;
    }
}

renderTab();
EOF

echo "COPNET-V2 Struktur wurde erstellt."
