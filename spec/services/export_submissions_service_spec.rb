require 'rails_helper'

RSpec.describe ExportSubmissionsService do
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let!(:submission) { create(:submission, phase: phase) }
  let!(:evaluator) { create(:user) }
  let!(:assignment) { create(:evaluator_submission_assignment, submission: submission, evaluator: evaluator) }
  let!(:evaluation) { create(:evaluation, evaluator_submission_assignment: assignment) }

  describe '#export' do
    context 'when exporting submissions' do
      let(:service) { described_class.new(phase, 'submissions') }
      let(:csv_content) { service.export }
      let(:parsed_csv) { CSV.parse(csv_content, headers: true) }

      it 'includes the correct headers' do
        expected_headers = [
          'Submission ID', 'Title', 'Brief Description', 'Description',
          'External URL', 'Status', 'Created At', 'Updated At',
          'Eligible for Evaluation', 'Selected to Advance'
        ]
        expect(parsed_csv.headers).to eq(expected_headers)
      end

      it 'includes the submission data' do
        row = parsed_csv.first
        expect(row['Submission ID']).to eq(submission.id.to_s)
        expect(row['Title']).to eq(submission.title)
        expect(row['Brief Description']).to eq(submission.brief_description || '')
        expect(row['Status']).to eq(submission.status)
        expect(row['Eligible for Evaluation']).to eq(submission.eligible_for_evaluation? ? 'Eligible' : 'Not Eligible')
        expect(row['Selected to Advance']).to eq(submission.selected_to_advance? ? 'Selected' : 'Not Selected')
      end

      it 'sanitizes text fields' do
        submission.update(description: '<p>Testing description sanitization of <script>js("xss")</script></p>')
        row = parsed_csv.first
        expect(row['Description']).to eq('Testing description sanitization of js("xss")')
      end
    end

    context 'when exporting evaluations' do
      let(:service) { described_class.new(phase, 'evaluations') }
      let(:csv_content) { service.export }
      let(:parsed_csv) { CSV.parse(csv_content, headers: true) }

      it 'includes the correct headers' do
        expected_headers = [
          'Submission ID', 'Evaluator Name', 'Evaluator Email',
          'Evaluation Status', 'Total Score'
        ]
        expect(parsed_csv.headers).to eq(expected_headers)
      end

      it 'includes the evaluation data' do
        row = parsed_csv.first
        expect(row['Submission ID']).to eq(submission.id.to_s)
        expect(row['Evaluator Name']).to eq("#{evaluator.first_name} #{evaluator.last_name}")
        expect(row['Evaluator Email']).to eq(evaluator.email)
        expect(row['Evaluation Status']).to eq(assignment.evaluation_status.to_s.titleize)
        expect(row['Total Score']).to eq(assignment.evaluation&.total_score&.to_i&.to_s || '')
      end

      it 'exports a row for each evaluator evaluation of the same submission' do
        evaluation_form = create(:evaluation_form)
        create(:evaluation_criterion, evaluation_form: evaluation_form, points_or_weight: 90)

        evaluation.update!(evaluation_form: evaluation_form)
        evaluation.update_column(:total_score, 90)

        evaluator2 = create(:user, role: 'evaluator', first_name: 'Santos', last_name: 'Bickford')
        assignment2 = create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator2,
          status: :assigned
        )
        evaluation2 = create(:evaluation,
          evaluator_submission_assignment: assignment2,
          evaluation_form: evaluation_form,
          completed_at: Time.current
        )
        evaluation2.update_column(:total_score, 85)

        evaluator_rows = parsed_csv.select { |row| row['Submission ID'] == submission.id.to_s }
        expect(evaluator_rows.length).to eq(2)

        expect(evaluator_rows[0]['Evaluator Name']).to eq("#{evaluator.first_name} #{evaluator.last_name}")
        expect(evaluator_rows[0]['Total Score']).to eq('90')

        expect(evaluator_rows[1]['Evaluator Name']).to eq('Santos Bickford')
        expect(evaluator_rows[1]['Total Score']).to eq('85')
      end
    end

    context 'with invalid options' do
      let(:service) { described_class.new(phase, 'invalid_option') }

      it 'returns nil when no valid export options are provided' do
        expect(service.export).to be_nil
      end
    end

    context 'when exporting attachments' do
      let(:service) { described_class.new(phase, 'attachments') }

      before do
        allow(Rails.configuration.phx_interop).to receive(:[]).with(:phx_uri)
          .and_return(ENV.fetch("PHOENIX_URI", nil))
      end

      it 'returns the correct phoenix download attachments URL' do
        result = service.export
        expected_path = "/challenges/#{challenge.id}/phases/#{phase.id}"

        expect(result[:status]).to eq(:see_other)
        expect(result[:redirect_url]).to eq("#{ENV.fetch('PHOENIX_URI', nil)}#{expected_path}")
      end
    end
  end
end
