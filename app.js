function changeTheme(theme) {
    document.body.className = theme;
    localStorage.setItem("copnet_theme", theme);
}

window.addEventListener("load", () => {
    const saved = localStorage.getItem("copnet_theme") || "theme-nrw";
    document.body.className = saved;
    document.getElementById("themeSelector").value = saved;
});
