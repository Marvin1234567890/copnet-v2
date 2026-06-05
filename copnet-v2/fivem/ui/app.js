window.addEventListener("message", (event) => {
    if (event.data.action === "open") {
        document.body.style.display = "flex";
    }
});

function closeTablet() {
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
    document.body.style.display = "none";
}
