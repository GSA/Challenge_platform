# frozen_string_literal: true

# Controller for managing saved challenges (bookmarks) for solvers.
class SavedChallengesController < ApplicationController
  before_action -> { authorize_user('solver') }

  def index
    @challenges_saved = current_user.challenges_saved
    @open_saved_challenges = @challenges_saved.open.includes([:agency, :sub_agency])
    @open_soon_saved_challenges = @challenges_saved.opening_soon.includes([:agency, :sub_agency])
    @closed_saved_challenges = @challenges_saved.closed.includes([:agency, :sub_agency])
  end

  def create
    saved_challenge = SavedChallenge.new(user: current_user, challenge_id: params[:challenge_id])
    saved_challenge.save
    # If save failed, the challenge is already saved (violates unique constraint)
    redirect_to saved_challenges_path, notice: I18n.t("solvers.alerts.challenge_saved")
  end

  def destroy
    current_user.saved_challenges.find_by!(challenge_id: params[:id]).destroy

    redirect_to saved_challenges_path, notice: I18n.t("solvers.alerts.challenge_removed")
  end
end
