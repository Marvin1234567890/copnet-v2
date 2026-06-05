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
        persons: "<h2>👤 Personenabfrage</h2><div class=card>Suche nach Personen…</div>",
        vehicles: "<h2>🚗 Fahrzeugabfrage</h2><div class=card>Suche nach Fahrzeugen…</div>",
        wanted: "<h2>📛 Fahndung</h2><div class=card>Wanted‑System aktiv…</div>",
        dispatch: "<h2>📞 Einsätze</h2><div class=card>Einsatzübersicht…</div>",
        duty: "<h2>🛡 Dienststatus</h2><div class=card>Dienstverwaltung…</div>",
        internal: "<h2>📂 Interne Ermittlungen</h2><div class=card>Interne Vorgänge…</div>",
        admin: "<h2>⚙ Adminbereich</h2><div class=card>Admin‑Tools…</div>"
    };

    c.innerHTML = pages[currentTab];
}