# frozen_string_literal: true

# Controller for the public solvers dashboard & routes
class SolversController < ApplicationController
  before_action -> { authorize_user('solver') }

  def dashboard
  end
end
