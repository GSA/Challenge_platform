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
RSpec.describe EvaluationFormsHelper, type: :helper do
  describe "challenge with phase" do
    it "concats challenge name with challenge phase" do
      user = create_user
      agency = Agency.create!(name: "Gandalf and Sons", acronym: "GAD")
      challenge = Challenge.create!(user:, agency:, title: "Pushing a boulder up a hill")
      form = EvaluationForm.create!(challenge_id: challenge.id, challenge_phase: 1)

      expect(helper.challenge_with_phase(form)).to eq("Pushing a boulder up a hill - Phase 1")
    end
  end
end
