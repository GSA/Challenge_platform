# frozen_string_literal: true

# Controller for managing saved challenges (bookmarks) for solvers.
class SavedChallengesController < ApplicationController
  before_action -> { authorize_user('solver') }

  def index
    saved_challenges = current_user.saved_challenges.includes([:agency, :sub_agency])
    @open_saved_challenges = saved_challenges.open
    @open_soon_saved_challenges = saved_challenges.opening_soon
    @closed_saved_challenges = saved_challenges.closed
  end
  def create
    saved_challenge = SavedChallenge.new(user: current_user, challenge_id: params[:challenge_id])

    if saved_challenge.save
      redirect_to saved_challenges_path, notice: "Challenge saved successfully."
    else
      redirect_to challenges_path, alert: "Failed to save challenge."
    end
  end
  def destroy
    challenge = current_user.saved_challenges.find(params[:id])
    current_user.saved_challenges.destroy(challenge)

    redirect_to saved_challenges_path, notice: "Challenge removed successfully."
  end
end
