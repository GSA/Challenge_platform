// app/javascript/controllers/evaluation_criteria_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "criteriaList",
    "template",
    "addButton",
    "criteriaRow",
    "scoringRadio",
    "binaryOptions",
    "ratingOptions",
    "scaleOptions",
    "hiddenOptionRangeStart",
    "hiddenOptionRangeEnd",
    "selectOptionRangeStart",
    "selectOptionRangeEnd",
    "criteriaLabelRow",
  ];

  connect() {
    this.counter = this.criteriaRowTargets.length;
  }

  addCriteria() {
    this.counter++;
    const newCriteria = this.templateTarget.cloneNode(true);

    this.replacePlaceholders(newCriteria);
    this.enableInputs(newCriteria);

    this.criteriaListTarget.appendChild(newCriteria);

    this.updateCriteriaTitles();
  }

  removeCriteria(event) {
    const row = event.target.closest(".criteria-row");
    const destroyField = row.querySelector(".destroy-evaluation-criteria");

    if (destroyField) {
      row.style.display = "none";
      destroyField.value = "true";
      this.disableInputs(row);
    } else {
      row.remove();
    }

    if (this.visibleRows().length == 0) {
      return this.addCriteria();
    }

    this.updateCriteriaTitles();
  }

  toggleScoringType(event) {
    const row = event.target.closest(".criteria-row");
    const scoringType = row.querySelector(".scoring-type-radio:checked").value;

    this.updateScoringOptions(row, scoringType);
  }

  toggleOptionRange(event) {
    const row = event.target.closest(".criteria-row");
    const start = row.querySelector(
      ".option-range-select.option-range-start"
    ).value;
    const end = row.querySelector(
      ".option-range-select.option-range-end"
    ).value;

    this.toggleOptionLabels(row, start, end);
  }

  replacePlaceholders(newCriteria) {
    newCriteria.setAttribute("data-evaluation-criteria-target", "criteriaRow");
    newCriteria.style.display = "block";
    newCriteria.removeAttribute("id");

    let accordionButton = newCriteria.querySelector(".usa-accordion__button");
    let accordionContent = newCriteria.querySelector(".usa-accordion__content");

    let accordionId = accordionContent
      .getAttribute("id")
      .replace("NEW_CRITERIA", this.counter);

    accordionButton.setAttribute("aria-controls", accordionId);
    accordionContent.setAttribute("id", accordionId);

    newCriteria.querySelectorAll("[id]").forEach((el) => {
      el.id = el.id.replace("NEW_CRITERIA", this.counter);
    });

    newCriteria.querySelectorAll("[name]").forEach((el) => {
      el.name = el.name.replace("NEW_CRITERIA", this.counter);
    });

    newCriteria.querySelectorAll("label").forEach((label) => {
      label.setAttribute(
        "for",
        label.getAttribute("for").replace("NEW_CRITERIA", this.counter)
      );
    });
  }

  updateCriteriaTitles() {
    this.visibleRows().forEach((row, index) => {
      const numberElement = row.querySelector(".criteria-number");
      numberElement.textContent = index + 1;
    });
  }

  updateScoringOptions(row, scoringType) {
    const scaleOptions = row.querySelector(".criteria-scale-options");
    const binaryOptions = row.querySelector(".criteria-binary-options");
    const ratingOptions = row.querySelector(".criteria-rating-options");
    const scaleOptionLabels = row.querySelector(
      ".criteria-scale-option-labels"
    );

    if (scoringType === "binary") {
      scaleOptions.style.display = "block";
      binaryOptions.style.display = "block";
      ratingOptions.style.display = "none";

      this.enableInputs(binaryOptions);
      this.disableInputs(ratingOptions);

      this.toggleOptionLabels(row, 0, 1);
    } else if (scoringType === "rating") {
      scaleOptions.style.display = "block";
      binaryOptions.style.display = "none";
      ratingOptions.style.display = "block";

      this.enableInputs(ratingOptions);
      this.disableInputs(binaryOptions);

      const start = parseInt(
        row.querySelector(".option-range-select.option-range-start").value
      );
      const end = parseInt(
        row.querySelector(".option-range-select.option-range-end").value
      );

      this.toggleOptionLabels(row, start, end);
    } else {
      scaleOptions.style.display = "none";
      binaryOptions.style.display = "none";
      ratingOptions.style.display = "none";

      this.disableInputs(binaryOptions);
      this.disableInputs(ratingOptions);
      this.disableInputs(scaleOptionLabels);
    }
  }

  toggleOptionLabels(row, start, end) {
    row
      .querySelectorAll(".criteria-option-label-row")
      .forEach((labelRow, index) => {
        labelRow.style.display =
          index >= start && index <= end ? "flex" : "none";
        const input = labelRow.querySelector("input");
        input.disabled = !(index >= start && index <= end);
      });
  }

  disableInputs(container) {
    container.querySelectorAll("input, select, textarea").forEach((input) => {
      if (input.type != "hidden") {
        input.disabled = true;
      }
    });
  }

  enableInputs(container) {
    container.querySelectorAll("input, select, textarea").forEach((input) => {
      input.disabled = false;
    });
  }

  visibleRows() {
    return this.criteriaRowTargets.filter(
      (row) => row.style.display !== "none"
    );
  }

  validateInputs(event) {
    let accordionButton = event.target.closest(".usa-accordion__button");
    let sectionId = accordionButton.getAttribute("aria-controls");
    let section = document.getElementById(sectionId);
    let requiredFields = section.querySelectorAll("[required]");

    for (let field of requiredFields) {
      if (!field.checkValidity()) {
        if (!field.reportValidity()) {
          event.preventDefault();
          event.stopPropagation();

          return false;
        }
      }
    }
    return true;
  }
}
