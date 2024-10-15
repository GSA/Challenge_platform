require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the EvaluationFormsHelper. For example:
#
# describe EvaluationFormsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe EvaluationFormsHelper do
  describe "challenge with phase" do
    it "concats challenge name with challenge phase" do
      user = create_user
      agency = Agency.create!(name: "Gandalf and Sons", acronym: "GAD")
      challenge = create_challenge(user:, agency:, title: "Pushing a boulder up a hill")
      phase = create_phase(challenge_id: challenge.id)
      form = create_evaluation_form(challenge_id: challenge.id, phase_id: phase.id)

      expect(helper.challenge_with_phase(form)).to eq("Pushing a boulder up a hill - Phase #{phase.id}")
    end
  end
end
