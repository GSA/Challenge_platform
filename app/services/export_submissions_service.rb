# frozen_string_literal: true

require 'csv'

# This service handles exporting submissions and evaluations into a csv.
class ExportSubmissionsService
  def initialize(phase, options)
    @phase = phase
    @options = options&.split(',') || []
  end

  def export
    if @options.include?('submissions') && @options.include?('evaluations')
      {
        submissions: create_submissions_csv,
        evaluations: create_evaluations_csv
      }
    elsif @options.include?('submissions')
      create_submissions_csv
    elsif @options.include?('evaluations')
      create_evaluations_csv
    end
  end

  private

  def sanitize_text(text)
    ActionView::Base.full_sanitizer.sanitize(text.to_s)
  end

  # submission csv
  def submissions_headers
    [
      'Submission ID', 'Title', 'Brief Description', 'Description',
      'External URL', 'Status', 'Created At', 'Updated At',
      'Eligible for Evaluation', 'Selected to Advance'
    ]
  end

  def submission_data(submission)
    [
      submission.id,
      submission.title || '',
      sanitize_text(submission.brief_description) || '',
      sanitize_text(submission.description) || '',
      submission.external_url || '',
      submission.status,
      submission.inserted_at,
      submission.updated_at,
      submission.eligible_for_evaluation? ? 'Eligible' : 'Not Eligible',
      submission.selected_to_advance? ? 'Selected' : 'Not Selected'
    ]
  end

  def create_submissions_csv
    CSV.generate(headers: true) do |csv|
      csv << submissions_headers
      @phase.submissions.find_each do |submission|
        csv << submission_data(submission)
      end
    end
  end

  # evaluations csv
  def evaluations_headers
    [
      'Submission ID', 'Evaluator Name', 'Evaluator Email',
      'Evaluation Status', 'Score'
    ]
  end

  def evaluation_data(submission, assignment)
    [
      submission.id,
      "#{assignment.evaluator.first_name || ''} #{assignment.evaluator.last_name || ''}",
      assignment.evaluator.email,
      assignment.evaluation_status.to_s.titleize,
      assignment.evaluation&.total_score || ''
    ]
  end

  def create_evaluations_csv
    CSV.generate(headers: true) do |csv|
      csv << evaluations_headers
      @phase.submissions.includes(evaluator_submission_assignments: [:evaluator, :evaluation]).find_each do |submission|
        submission.evaluator_submission_assignments.each do |assignment|
          csv << evaluation_data(submission, assignment)
        end
      end
    end
  end
end
