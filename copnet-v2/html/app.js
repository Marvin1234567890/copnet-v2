let currentTab = "persons";

const demo = {
    persons: [
        {
            name: "Mustermann",
            vorname: "Max",
            geburtsdatum: "1990-01-01",
            adresse: "Köln, Musterstraße 1",
            staatsangehoerigkeit: "Deutsch",
            geschlecht: "Männlich",
            telefon: "0151 12345678",
            dienststelle: "Polizei Köln"
        }
    ],
    vehicles: [
        {
            plate: "K-MX-1234",
            hersteller: "BMW",
            modell: "3er Touring",
            farbe: "Blau",
            image: "https://upload.wikimedia.org/wikipedia/commons/3/3d/BMW_3er_Polizei_NRW.jpg"
        }
    ],
    wanted: [
        {
            person: "Max Mustermann",
            reason: "§242 StGB – Diebstahl",
            level: "mittel",
            aktenzeichen: "NRW-2026-0001"
        }
    ],
    dispatch: [
        {
            caller: "Anwohner",
            location: "Köln Innenstadt",
            description: "Ruhestörung im Hinterhof",
            type: "Ruhestörung",
            priority: "mittel",
            coords: "51.0, 7.0"
        }
    ],
    duty: [
        {
            user_id: 1,
            status: "Im Dienst",
            last_change: "2026-06-05 02:30:00"
        }
    ],
    internal: [
        {
            title: "Interne Ermittlung 001",
            status: "laufend",
            description: "Prüfung eines Einsatzes"
        }
    ],
    admin: [
        {
            id: 1,
            name: "PHK Müller",
            rank: "Polizeihauptkommissar",
            dienststelle: "Polizei Köln"
        }
    ]
};

function changeTheme(theme) {
    document.body.className = theme;
    localStorage.setItem("copnet_theme", theme);
}

function toggleMode() {
    document.body.classList.toggle("light");
}

window.addEventListener("load", () => {
    const saved = localStorage.getItem("copnet_theme") || "theme-nrw";
    document.body.className = saved;
    const sel = document.getElementById("themeSelector");
    if (sel) sel.value = saved;
    renderTab();
});

function setTab(tab) {
    currentTab = tab;
    renderTab();
}

function renderTab() {
    const c = document.getElementById("content");

    const templates = {
        persons: `
            <h2>👤 Personenabfrage</h2>
            <input id="searchInput" placeholder="Name eingeben...">
            <button onclick="searchData()">Suchen</button>
            <div id="results"></div>
        `,
        vehicles: `
            <h2>🚗 Fahrzeugabfrage</h2>
            <input id="searchInput" placeholder="Kennzeichen eingeben...">
            <button onclick="searchData()">Suchen</button>
            <div id="results"></div>
        `,
        wanted: `
            <h2>📛 Fahndung</h2>
            <div class="card">
                <div class="card-title">📄 Neuen Wanted-Eintrag erstellen</div>
                <div class="card-row">
                    <b>Person:</b><br>
                    <input id="wanted_person" placeholder="Name eingeben...">
                </div>
                <div class="card-row">
                    <b>Grund:</b><br>
                    <input id="wanted_reason" placeholder="Straftat / Grund...">
                </div>
                <div class="card-row">
                    <b>Level:</b><br>
                    <select id="wanted_level">
                        <option value="niedrig">Niedrig</option>
                        <option value="mittel">Mittel</option>
                        <option value="hoch">Hoch</option>
                    </select>
                </div>
                <button onclick="addWanted()">Eintrag erstellen</button>
            </div>
            <h3 style="margin-top:20px;">📋 Bestehende Fahndungen</h3>
            <div id="results"></div>
        `,
        dispatch: `
            <h2>📞 Einsätze</h2>
            <div id="results"></div>
        `,
        duty: `<h2>🛡 Dienst</h2><div id="results"></div>`,
        internal: `<h2>📂 Interne Ermittlungen</h2><div id="results"></div>`,
        admin: `<h2>⚙ Admin</h2><div id="results"></div>`
    };

    c.innerHTML = templates[currentTab];
    renderResults(demo[currentTab]);
}

function searchData() {
    const input = document.getElementById("searchInput");
    if (!input) return;
    const query = input.value.toLowerCase();
    const filtered = demo[currentTab].filter(item =>
        JSON.stringify(item).toLowerCase().includes(query)
    );
    renderResults(filtered);
}

function addWanted() {
    const person = document.getElementById("wanted_person").value;
    const reason = document.getElementById("wanted_reason").value;
    const level = document.getElementById("wanted_level").value;

    if (!person || !reason) return alert("Bitte alle Felder ausfüllen!");

    demo.wanted.push({
        person,
        reason,
        level,
        aktenzeichen: "NRW-2026-" + String(demo.wanted.length + 1).padStart(4, "0")
    });

    renderTab();
}

function renderResults(data) {
    const r = document.getElementById("results");
    if (!r) return;
    r.innerHTML = "";

    if (!data || data.length === 0) {
        r.innerHTML = `<div class="card">Keine Daten gefunden.</div>`;
        return;
    }

    data.forEach(item => {
        let html = "";

        if (currentTab === "persons") {
            html = `
                <div class="card">
                    <div class="card-title">👤 ${item.vorname} ${item.name}</div>
                    <div class="card-row"><b>Geburtsdatum:</b> ${item.geburtsdatum}</div>
                    <div class="card-row"><b>Adresse:</b> ${item.adresse}</div>
                    <div class="card-row"><b>Telefon:</b> ${item.telefon}</div>
                    <div class="card-row"><b>Dienststelle:</b> ${item.dienststelle}</div>
                </div>
            `;
        }

        if (currentTab === "vehicles") {
            html = `
                <div class="card">
                    <div class="card-title">🚗 ${item.hersteller} ${item.modell}</div>
                    <img src="${item.image}" class="vehicle-img">
                    <div class="card-row"><b>Kennzeichen:</b> ${item.plate}</div>
                    <div class="card-row"><b>Farbe:</b> ${item.farbe}</div>
                </div>
            `;
        }

        if (currentTab === "wanted") {
            const levelColor = {
                niedrig: "badge-info",
                mittel: "badge-warn",
                hoch: "badge-danger"
            }[item.level] || "badge-info";

            html = `
                <div class="card">
                    <div class="card-title">📛 ${item.person}</div>
                    <div class="card-row"><b>Grund:</b> ${item.reason}</div>
                    <div class="card-row"><b>Aktenzeichen:</b> ${item.aktenzeichen}</div>
                    <div class="card-row"><span class="badge ${levelColor}">${item.level.toUpperCase()}</span></div>
                </div>
            `;
        }

        if (currentTab === "dispatch") {
            const icons = {
                "Ruhestörung": "🔊",
                "Verkehrsunfall": "🚧",
                "Körperverletzung": "🩸",
                "Einbruch": "🏚️",
                "Vermisste Person": "🧍‍♂️❓",
                "Bewaffnete Person": "🔫",
                "Raubüberfall": "💰❗",
                "Drogenfund": "🌿"
            };

            html = `
                <div class="card">
                    <div class="card-title">${icons[item.type] || "📞"} ${item.location}</div>
                    <div class="card-row"><b>Anrufer:</b> ${item.caller}</div>
                    <div class="card-row"><b>Beschreibung:</b> ${item.description}</div>
                    <div class="card-row"><b>Priorität:</b> ${item.priority}</div>
                    <div class="card-row"><b>Koordinaten:</b> ${item.coords}</div>
                </div>
            `;
        }

        if (currentTab === "duty") {
            html = `
                <div class="card">
                    <div class="card-title">🛡 Beamter ID: ${item.user_id}</div>
                    <div class="card-row"><b>Status:</b> ${item.status}</div>
                    <div class="card-row"><b>Letzte Änderung:</b> ${item.last_change}</div>
                </div>
            `;
        }

        if (currentTab === "internal") {
            html = `
                <div class="card">
                    <div class="card-title">📂 ${item.title}</div>
                    <div class="card-row"><b>Status:</b> ${item.status}</div>
                    <div class="card-row"><b>Beschreibung:</b> ${item.description}</div>
                </div>
            `;
        }

        if (currentTab === "admin") {
            html = `
                <div class="card">
                    <div class="card-title">⚙ ${item.name}</div>
                    <div class="card-row"><b>ID:</b> ${item.id}</div>
                    <div class="card-row"><b>Dienstgrad:</b> ${item.rank}</div>
                    <div class="card-row"><b>Dienststelle:</b> ${item.dienststelle}</div>
                </div>
            `;
        }

        r.innerHTML += html;
    });
}

