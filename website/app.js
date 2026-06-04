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
