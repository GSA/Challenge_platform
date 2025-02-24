# == Schema Information
#
# Table name: phases
#
#  id                     :bigint           not null, primary key
#  challenge_id           :bigint           not null
#  uuid                   :uuid             not null
#  title                  :string(255)
#  start_date             :datetime
#  end_date               :datetime
#  open_to_submissions    :boolean
#  judging_criteria       :text
#  judging_criteria_delta :text
#  how_to_enter           :text
#  how_to_enter_delta     :text
#  inserted_at            :datetime         not null
#  updated_at             :datetime         not null
#  submissions_count      :integer          default(0), not null
#
require 'rails_helper'

RSpec.describe Phase, type: :model do
  let(:phase) { create(:phase) }

  describe "evaluation status" do
    context "with no submissions" do
      it "returns not started" do
        expect(phase.evaluation_status).to eq(:not_started)
      end
    end

    context 'when a submission is assigned to an evaluator but no evaluations are in progress' do
      let!(:submission) { create(:submission, phase: phase, judging_status: "selected") }
      let!(:evaluator) { create(:user, role: :evaluator) }
      let!(:assignment) do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator,
          status: :assigned)
      end

      it 'returns not_started' do
        expect(phase.evaluation_status).to eq(:not_started)
      end
    end  

    context 'when an evaluation is in progress but not completed' do
      let!(:submission) { create(:submission, phase: phase, judging_status: "selected") }
      let!(:evaluator) { create(:user, role: :evaluator) }
      let!(:assignment) do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator,
          status: :assigned)
      end

      before do
        create(:evaluation,
          evaluator_submission_assignment: assignment,
          submission: submission,
          completed_at: nil)
      end

      it 'returns in_progress' do
        expect(phase.evaluation_status).to eq(:in_progress)
      end
    end

    context 'when some evaluations are completed but some are in progress' do
      let!(:submission) { create(:submission, phase: phase, judging_status: "selected") }
      let!(:evaluator) { create(:user, role: :evaluator) }
      let!(:evaluator2) { create(:user, role: :evaluator) }
      let!(:assignment) do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator,
          status: :assigned)
      end
      let!(:assignment2) do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator2,
          status: :assigned)
      end

      before do
        create(:evaluation,
          evaluator_submission_assignment: assignment,
          submission: submission,
          completed_at: nil)
        create(:evaluation,
          evaluator_submission_assignment: assignment2,
          submission: submission,
          completed_at: Time.current)
      end

      it 'returns in_progress' do
        expect(phase.evaluation_status).to eq(:in_progress)
      end
    end

    context 'when all evaluations are complete' do
      let!(:submission) { create(:submission, phase: phase, judging_status: "selected") }
      let!(:evaluator) { create(:user, role: :evaluator) }
      let!(:evaluator2) { create(:user, role: :evaluator) }
      let!(:assignment) do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator,
          status: :assigned)
      end
      let!(:assignment2) do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator2,
          status: :assigned)
      end

      before do
        create(:evaluation,
          evaluator_submission_assignment: assignment,
          submission: submission,
          completed_at: Time.current)
        create(:evaluation,
          evaluator_submission_assignment: assignment2,
          submission: submission,
          completed_at: Time.current)
      end

      it 'returns completed' do
        expect(phase.evaluation_status).to eq(:completed)
      end
    end
  end  
end  