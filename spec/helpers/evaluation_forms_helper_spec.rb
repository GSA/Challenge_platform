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
  describe "#challenge_with_phase" do
    it "only shows challenge name with single phase challenge" do
      user = create_user
      agency = Agency.create!(name: "Gandalf and Sons", acronym: "GAD")
      challenge = create(:challenge, user:, agency:, is_multi_phase: false, title: "Pushing a boulder up a hill")
      phase = challenge.phases.first
      form = create_evaluation_form(challenge_id: challenge.id, phase_id: phase.id)

      expect(helper.challenge_with_phase(form)).to eq("Pushing a boulder up a hill")
    end

    it "concats challenge name with challenge phase" do
      user = create_user
      agency = Agency.create!(name: "Gandalf and Sons", acronym: "GAD")
      challenge = create(:challenge, user:, agency:, is_multi_phase: true, title: "Pushing a boulder up a hill")
      phase = challenge.phases.first
      form = create_evaluation_form(challenge_id: challenge.id, phase_id: phase.id)

      expect(helper.challenge_with_phase(form)).to eq("Pushing a boulder up a hill - Phase 1")
    end
  end

  describe "#challenge_phase_title" do
    it "only shows challenge name with single phase challenge" do
      user = create_user
      agency = Agency.create!(name: "Gandalf and Sons", acronym: "GAD")
      challenge = create(:challenge, user:, agency:, is_multi_phase: false, title: "Pushing a boulder up a hill")
      phase = challenge.phases.first

      expect(helper.challenge_phase_title(challenge, phase)).to eq("Pushing a boulder up a hill")
    end

    it "concats challenge name with challenge phase" do
      user = create_user
      agency = Agency.create!(name: "Gandalf and Sons", acronym: "GAD")
      challenge = create(:challenge, user:, agency:, is_multi_phase: true, title: "Pushing a boulder up a hill")
      phase = challenge.phases.first

      expect(helper.challenge_phase_title(challenge, phase)).to eq("Pushing a boulder up a hill - Phase 1")
    end
  end
end
