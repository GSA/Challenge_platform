# frozen_string_literal: true

require 'rails_helper'

describe "A11y", :js do
  describe "Logged-in as a Challenge Manager" do
    let(:user) { create_user(role: "challenge_manager") }
    let(:challenge) { create_challenge(user: user, title: "Boston Tea Party Cleanup") }
    let(:submission) { create(:submission, manager: user, challenge: challenge) }


    before { system_login_user(user) }

    it "submission details page is accessible" do
      visit submission_path(submission)
      expect(user.role).to eq("challenge_manager")
      expect(page).to have_content(submission.id)
      expect(page).to(be_axe_clean)
    end

    it "allows manipulation of judging status" do
      visit submission_path(submission)

      find_by_id('eligible-for-evaluation').click
      updated_submission = Submission.find(submission.id)
      expect(updated_submission.judging_status).to eq('selected')

      find('#selected-to-advance').click
      updated_submission = Submission.find(submission.id)
      expect(updated_submission.judging_status).to eq('winner')
    end

    it "saves comments" do
      visit submission_path(submission)
      comments = Faker::Lorem.sentence

      fill_in "Comments and notes:", with: comments
      click_on('Save')
      updated_submission = Submission.find(submission.id)
      expect(updated_submission.comments).to eq(comments)
    end
  end
end
