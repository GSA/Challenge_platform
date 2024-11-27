# frozen_string_literal: true

# Controller for evaluations CRUD actions.
class EvaluationsController < ApplicationController
  before_action -> { authorize_user('evaluator') }
  def index; end
end
