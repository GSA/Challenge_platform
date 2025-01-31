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
        expect(row['Score']).to eq(assignment.evaluation&.total_score&.to_s || '')
      end

      it 'exports a row for each evaluator evaluation of the same submission' do
        evaluation.update!(total_score: 90)

        evaluator2 = create(:user, role: 'evaluator', first_name: 'Santos', last_name: 'Bickford')
        assignment2 = create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator2,
          status: :assigned
        )
        create(:evaluation,
          evaluator_submission_assignment: assignment2,
          total_score: 85
        )

        evaluator_rows = parsed_csv.select { |row| row['Submission ID'] == submission.id.to_s }
        expect(evaluator_rows.length).to eq(2)

        expect(evaluator_rows[0]['Evaluator Name']).to eq("#{evaluator.first_name} #{evaluator.last_name}")
        expect(evaluator_rows[0]['Score']).to eq('90')

        expect(evaluator_rows[1]['Evaluator Name']).to eq('Santos Bickford')
        expect(evaluator_rows[1]['Score']).to eq('85')
      end
    end

    context 'when exporting both submissions and evaluations' do
      let(:service) { described_class.new(phase, 'submissions,evaluations') }
      let(:export_data) { service.export }

      it 'returns both CSV data' do
        expect(export_data).to have_key(:submissions)
        expect(export_data).to have_key(:evaluations)
      end

      it 'includes valid CSV data for both exports' do
        submissions_csv = CSV.parse(export_data[:submissions], headers: true)
        evaluations_csv = CSV.parse(export_data[:evaluations], headers: true)

        expect(submissions_csv.first['Submission ID']).to eq(submission.id.to_s)
        expect(evaluations_csv.first['Submission ID']).to eq(submission.id.to_s)
      end
    end

    context 'with invalid options' do
      let(:service) { described_class.new(phase, 'invalid_option') }

      it 'returns nil when no valid export options are provided' do
        expect(service.export).to be_nil
      end
    end
  end
end
