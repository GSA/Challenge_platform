# frozen_string_literal: true

class ManageSubmissionsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  def index
    @challenges = current_user.challenge_manager_challenges
  end
end
