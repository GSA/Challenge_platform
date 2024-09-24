# frozen_string_literal: true

class EvaluationFormsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  def index; end
end
