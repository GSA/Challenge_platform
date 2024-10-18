document.addEventListener("DOMContentLoaded", function () {
  let criteriaCounter = document.querySelectorAll(".criteria-row").length;
  let criteriaList = document.getElementById("criteria-list");
  let addCriteriaButton = document.getElementById("add-criteria-button");

  // Add Criteria Button
  if (addCriteriaButton) {
    addCriteriaButton.addEventListener("click", function () {
      createNewCriteriaRow();
    });
  }

  // Remove Criteria Button
  if (criteriaList) {
    criteriaList.addEventListener("click", function (event) {
      if (event.target.classList.contains("delete-criteria-button")) {
        let criteriaList = document.getElementById("criteria-list");
        let criteriaRow = event.target.closest(".criteria-row");

        // Don't count hidden criteria rows marked for deletion
        let visibleCriteriaRows = Array.from(criteriaList.children).filter(
          (row) => row.style.display !== "none"
        );

        if (visibleCriteriaRows.length > 1) {
          destroyCriteriaRow(criteriaRow);
        } else {
          destroyCriteriaRow(criteriaRow);
          createNewCriteriaRow();
        }
      }
    });
  }

  function createNewCriteriaRow() {
    let template = document.getElementById("criteria-template");
    let newCriteria = template.cloneNode(true);

    criteriaCounter++;

    newCriteria.style.display = "block";
    newCriteria.removeAttribute("id");

    newCriteria.querySelectorAll("input, textarea").forEach(function (input) {
      let id = input.getAttribute("id");
      let name = input.getAttribute("name");

      // TODO: Remove condition when adding other scoring types
      if (input.type !== "radio") {
        input.disabled = false;
      }

      if (id) {
        let newId = id.replace("NEW_CRITERIA", criteriaCounter);
        input.setAttribute("id", newId);
      }

      if (name) {
        let newName = name.replace("NEW_CRITERIA", criteriaCounter);
        input.setAttribute("name", newName);
      }
    });

    document.getElementById("criteria-list").appendChild(newCriteria);
  }

  function destroyCriteriaRow(criteriaRow) {
    let idField = criteriaRow.querySelector("input[name*='[id]']");
    let destroyField = criteriaRow.querySelector(
      ".destroy-evaluation-criteria"
    );

    if (idField) {
      // If existing evaluation criteria mark for destruction
      criteriaRow.style.display = "none";
      destroyField.value = "true";

      criteriaRow.querySelectorAll("input, textarea").forEach(function (input) {
        // Preserve hidden id and _destroy inputs
        if (input.type !== "hidden") {
          // Disable inputs to prevent unfocusable browser error
          input.disabled = true;
        }
      });
    } else {
      // Otherwise remove row entirely
      criteriaRow.remove();
    }
  }
});
