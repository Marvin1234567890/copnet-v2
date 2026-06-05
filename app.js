let currentTab = "persons";

function changeTheme(theme) {
    document.body.className = theme;
    localStorage.setItem("copnet_theme", theme);
}

window.addEventListener("load", () => {
    const saved = localStorage.getItem("copnet_theme") || "theme-nrw";
    document.body.className = saved;
    document.getElementById("themeSelector").value = saved;
    renderTab();
});

function setTab(tab) {
    currentTab = tab;
    renderTab();
}

function renderTab() {
    const c = document.getElementById("content");

    const pages = {
        persons: `
            <h2>👤 Personenabfrage</h2>
            <div class="card">
                <label>Nachname:</label>
                <input type="text" placeholder="z.B. Müller">
                <label>Vorname:</label>
                <input type="text" placeholder="z.B. Peter">
                <button>Person suchen</button>
            </div>
        `,
        vehicles: `
            <h2>🚗 Fahrzeugabfrage</h2>
            <div class="card">
                <label>Kennzeichen:</label>
                <input type="text" placeholder="z.B. BOT-M 1234">
                <label>Fahrzeugtyp:</label>
                <input type="text" placeholder="z.B. BMW 3er">
                <button>Fahrzeug suchen</button>
            </div>
        `,
        wanted: `
            <h2>📛 Fahndungssystem</h2>
            <div class="card">
                <label>Person:</label>
                <input type="text" placeholder="Name">
                <label>Grund:</label>
                <input type="text" placeholder="Tatvorwurf">
                <label>Level:</label>
                <select>
                    <option>LOW</option>
                    <option>MEDIUM</option>
                    <option>HIGH</option>
                </select>
                <label>Aktenzeichen:</label>
                <input type="text" placeholder="z.B. NRW-2025-0001">
                <button>Fahndung anlegen</button>
            </div>
        `,
        dispatch: `
            <h2>📞 Einsätze</h2>
            <div class="card">
                <label>Einsatzart:</label>
                <input type="text" placeholder="z.B. Verkehrsunfall">
                <label>Priorität:</label>
                <select>
                    <option>PRIO 1</option>
                    <option>PRIO 2</option>
                    <option>PRIO 3</option>
                </select>
                <label>Koordinaten:</label>
                <input type="text" placeholder="x, y, z">
                <button>Einsatz erstellen</button>
            </div>
        `,
        duty: `
            <h2>🛡 Dienststatus</h2>
            <div class="card">
                <label>Beamter:</label>
                <input type="text" placeholder="Name">
                <label>Status:</label>
                <select>
                    <option>Im Dienst</option>
                    <option>Außer Dienst</option>
                    <option>Pause</option>
                </select>
                <button>Status aktualisieren</button>
            </div>
        `,
        internal: `
            <h2>📂 Interne Ermittlungen</h2>
            <div class="card">
                <label>Vorgang:</label>
                <input type="text" placeholder="Vorgangsbezeichnung">
                <label>Status:</label>
                <select>
                    <option>Offen</option>
                    <option>Laufend</option>
                    <option>Abgeschlossen</option>
                </select>
                <button>Vorgang speichern</button>
            </div>
        `,
        admin: `
            <h2>⚙ Adminbereich</h2>
            <div class="card">
                <label>Beamter:</label>
                <input type="text" placeholder="Name">
                <label>Dienstgrad:</label>
                <input type="text" placeholder="z.B. PHK">
                <label>Dienststelle:</label>
                <input type="text" placeholder="z.B. PD Marl">
                <button>Beamten speichern</button>
            </div>
        `
    };

    c.innerHTML = pages[currentTab];
}