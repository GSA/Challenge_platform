# frozen_string_literal: true

# Controller for displaying submission materials to managers and evaluators.
class SubmissionMaterialsController < ApplicationController
  before_action -> { authorize_user('challenge_manager', 'evaluator') }
  before_action -> { check_gov_access }

  def show
    @submission = Submission.by_user(current_user).find(params[:id])
  end
end
