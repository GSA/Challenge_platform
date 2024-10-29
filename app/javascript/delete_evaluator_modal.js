export function initializeDeleteEvaluatorModal() {
  let currentEvaluatorId, currentEvaluatorType, challengeId, phaseId;

  document.querySelectorAll('[data-open-modal]').forEach(button => {
    button.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      currentEvaluatorId = button.dataset.evaluatorId;
      currentEvaluatorType = button.dataset.evaluatorType;
      challengeId = button.dataset.challengeId;
      phaseId = button.dataset.phaseId;
      const modal = document.getElementById('delete-evaluator-modal');
      modal.classList.add('is-visible');
      return false;
    });
  });

  document.getElementById('confirmDelete').addEventListener('click', () => {
    deleteEvaluator();
  });

  function deleteEvaluator(forceDelete = false) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    const challengeId = document.querySelector('[data-challenge-id]').dataset.challengeId;
  
    fetch(`/challenges/${challengeId}/manage_evaluators`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        evaluator_id: currentEvaluatorId,
        evaluator_type: currentEvaluatorType,
        phase_id: phaseId,
        force_delete: forceDelete
      })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json();
    })
    .then(data => {
      if (data.success) {
        const modal = document.getElementById('delete-evaluator-modal');
        modal.classList.remove('is-visible');
        window.location.reload();
      } else {
        throw new Error(data.message || 'Failed to remove evaluator');
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert(error.message || 'An error occurred while removing the evaluator');
    });
  }

  document.querySelectorAll('[data-close-modal]').forEach(element => {
    element.addEventListener('click', () => {
      const modal = document.getElementById('delete-evaluator-modal');
      modal.classList.remove('is-visible');

      const modalDescription = document.getElementById('modal-1-description');
      modalDescription.textContent = 'Deleting an evaluator from the challenge will remove the evaluator from any submissions of this challenge that the evaluator is assigned to. It will also delete any of their completed or in progress evaluations for those submissions.';
      
      const confirmButton = document.getElementById('confirmDelete');
      confirmButton.textContent = 'Yes';
      confirmButton.onclick = () => deleteEvaluator();
    });
  });
}

if (document.querySelector('[data-page="manage-evaluators"]')) {
  document.addEventListener('DOMContentLoaded', initializeDeleteEvaluatorModal);
}
