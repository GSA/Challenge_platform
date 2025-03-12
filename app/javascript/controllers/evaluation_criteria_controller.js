// app/javascript/controllers/evaluation_criteria_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["criteriaList", "template", "criteriaRow"];

  connect() {
    // -1 to match the 0 indexed eval criteria elements
    this.counter = this.criteriaRowTargets.length - 1;
    this.toggleRemoveCriteriaButtons();
  }

  addCriteria() {
    this.counter++;
    const newCriteria = this.templateTarget.cloneNode(true);

    this.replacePlaceholders(newCriteria);
    this.enableInputs(newCriteria);

    this.collapseAllCriteria();
    this.expandCriterion(newCriteria);

    this.criteriaListTarget.appendChild(newCriteria);

    this.toggleRemoveCriteriaButtons();
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

    this.toggleRemoveCriteriaButtons();
    this.updateCriteriaTitles();
  }

  collapseAllCriteria() {
    const accordionButtons = this.element.querySelectorAll(
      ".usa-accordion__button"
    );
    const accordions = this.element.querySelectorAll(".usa-accordion__content");

    accordionButtons.forEach((button) =>
      button.setAttribute("aria-expanded", false)
    );
    accordions.forEach((content) => content.setAttribute("hidden", ""));
  }

  expandCriterion(criterion) {
    const accordionButton = criterion.querySelector(".usa-accordion__button");
    const accordionContent = criterion.querySelector(".usa-accordion__content");

    if (accordionButton) accordionButton.setAttribute("aria-expanded", true);
    if (accordionContent) accordionContent.removeAttribute("hidden");
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

    // TODO: Fix criteria indexing for easier testing of new criteria added
    newCriteria.setAttribute("data-index", this.counter);

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
      const criteriaNumberElements = row.querySelectorAll(".criteria-number");
      criteriaNumberElements.forEach((element, _index) => {
        element.textContent = index + 1;
      });
    });
  }

  checkPointsOrWeightMax(event) {
    const input = event.target;
    const min = parseInt(input.min);
    const max = parseInt(input.max);
    const value = parseInt(input.value);

    // If invalid value is entered then pop up error message
    if (value && (value < min || value > max)) {
      event.target.reportValidity();
    }
  }

  updateScoringOptions(row, scoringType) {
    const options = {
      scaleOptions: row.querySelector(".criteria-scale-options"),
      binaryOptions: row.querySelector(".criteria-binary-options"),
      ratingOptions: row.querySelector(".criteria-rating-options"),
      scaleOptionLabels: row.querySelector(".criteria-scale-option-labels"),
    };

    switch (scoringType) {
      case "binary":
        this.setScaleOptionsMainLabel(row, "Binary Scale Options");
        this.showBinaryOptions(options);
        this.toggleOptionLabels(row, 0, 1);
        break;
      case "rating":
        this.setScaleOptionsMainLabel(row, "Rating Scale Options");
        this.showRatingOptions(row, options);
        break;
      default:
        this.hideAllOptions(options);
        break;
    }
  }

  setScaleOptionsMainLabel(row, text) {
    row.querySelector(".scale-options-main-label").textContent = text;
  }

  showBinaryOptions(options) {
    options.scaleOptions.style.display = "block";
    options.binaryOptions.style.display = "block";
    options.ratingOptions.style.display = "none";
    this.enableInputs(options.binaryOptions);
    this.disableInputs(options.ratingOptions);
  }

  showRatingOptions(row, options) {
    options.scaleOptions.style.display = "block";
    options.binaryOptions.style.display = "none";
    options.ratingOptions.style.display = "block";
    this.enableInputs(options.ratingOptions);
    this.disableInputs(options.binaryOptions);
    const start = parseInt(
      row.querySelector(".option-range-select.option-range-start").value
    );
    const end = parseInt(
      row.querySelector(".option-range-select.option-range-end").value
    );
    this.toggleOptionLabels(row, start, end);
  }

  hideAllOptions(options) {
    options.scaleOptions.style.display = "none";
    options.binaryOptions.style.display = "none";
    options.ratingOptions.style.display = "none";
    this.disableInputs(options.binaryOptions);
    this.disableInputs(options.ratingOptions);
    this.disableInputs(options.scaleOptionLabels);
  }

  toggleOptionLabels(row, start, end) {
    row
      .querySelectorAll(".criteria-option-label-row")
      .forEach((labelRow, index) => {
        labelRow.style.display =
          index >= start && index <= end ? "block" : "none";
        const input = labelRow.querySelector("input");
        input.disabled = index < start || index > end;
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
    const section = document.getElementById(
      event.target
        .closest(".usa-accordion__button")
        .getAttribute("aria-controls")
    );

    if (this.checkRequiredFields(section)) {
      return true;
    } else {
      event.preventDefault();
      event.stopPropagation();
      return false;
    }
  }

  checkRequiredFields(section) {
    return Array.from(section.querySelectorAll("[required]")).every((field) =>
      field.reportValidity()
    );
  }

  toggleRemoveCriteriaButtons() {
    let show = this.visibleRows().length > 1;
    this.element
      .querySelectorAll(".delete-criteria-button")
      .forEach((button) => {
        button.classList.toggle("display-none", !show);
      });
  }
}
