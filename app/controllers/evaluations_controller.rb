# frozen_string_literal: true

class EvaluationsController < ApplicationController
  before_action -> { authorize_user('evaluator') }
  def index; end
end
