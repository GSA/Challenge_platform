document.addEventListener("DOMContentLoaded", function () {
    document.getElementById("evaluation_form_instructions").addEventListener("input", (e ) => {
        document.getElementById("character_counter").innerHTML = 3000 - e.target.value.length
    })
})    