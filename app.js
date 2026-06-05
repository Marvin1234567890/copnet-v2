let currentTab = "persons";

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
            <button class="action" onclick="searchPerson()">Suchen</button>
            <div id="results"></div>
        `;
    }

    if (currentTab === "vehicles") {
        c.innerHTML = `
            <h2>Fahrzeugabfrage</h2>
            <input id="plate" placeholder="Kennzeichen...">
            <button class="action" onclick="searchVehicle()">Suchen</button>
            <div id="results"></div>
        `;
    }

    if (currentTab === "wanted") {
        c.innerHTML = `
            <h2>Wanted-System</h2>
            <input id="wpid" placeholder="Personen-ID">
            <input id="wlevel" placeholder="Wanted-Level (0-5)">
            <textarea id="wnotes" placeholder="Notizen"></textarea>
            <button class="action" onclick="setWanted()">Speichern</button>
            <button class="action" onclick="getWanted()">Abrufen</button>
            <div id="wresult"></div>
        `;
    }

    if (currentTab === "dispatch") {
        c.innerHTML = `
            <h2>Leitstelle</h2>
            <input id="dtitle" placeholder="Titel">
            <input id="dloc" placeholder="Ort">
            <textarea id="ddesc" placeholder="Beschreibung"></textarea>
            <button class="action" onclick="createDispatch()">Einsatz erstellen</button>
            <button class="action" onclick="getDispatch()">Einsätze laden</button>
            <div id="dlist"></div>
        `;
    }
}

renderTab();
async function searchPerson() {
    const q = document.getElementById("pquery").value;
    const res = await fetch(`/api/persons/search?q=${encodeURIComponent(q)}`);
    const data = await res.json();
    const r = document.getElementById("results");
    r.innerHTML = data.map(p => `
        <div class="result">
            <strong>${p.name}</strong><br>
            Geburtsdatum: ${p.geburtsdatum || "-"}<br>
            Adresse: ${p.adresse || "-"}<br>
            Bemerkung: ${p.bemerkung || "-"}
        </div>
    `).join("");
}

async function searchVehicle() {
    const plate = document.getElementById("plate").value;
    const res = await fetch(`/api/vehicles/search?plate=${encodeURIComponent(plate)}`);
    const data = await res.json();
    const r = document.getElementById("results");
    r.innerHTML = data.map(v => `
        <div class="result">
            <strong>${v.plate}</strong><br>
            Modell: ${v.model || "-"}<br>
            Farbe: ${v.color || "-"}<br>
            Halter: ${v.owner_name || "-"}
        </div>
    `).join("");
}
if (currentTab === "internal") {
    c.innerHTML = `
        <h2>Interne Ermittlungen</h2>
        <button class="action" onclick="loadInternalCases()">Fälle laden</button>
        <div id="results"></div>
    `;
}

async function loadInternalCases() {
    const res = await fetch("/api/cases?type=interne_ermittlung");
    const data = await res.json();
    const r = document.getElementById("results");
    r.innerHTML = data.map(cs => `
        <div class="result">
            <strong>${cs.title}</strong><br>
            Status: ${cs.status}<br>
            Erstellt am: ${cs.created_at}
        </div>
    `).join("");
}

