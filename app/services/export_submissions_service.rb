# frozen_string_literal: true

require 'csv'

# This service handles exporting submissions and evaluations into a csv.
class ExportSubmissionsService
  def initialize(phase, options)
    @phase = phase
    @options = options&.split(',') || []
  end

  def export
    export_actions = {
      'attachments' => :redirect_to_phoenix_submission_attachments,
      'submissions' => :create_submissions_csv,
      'evaluations' => :create_evaluations_csv
    }

    action = export_actions[@options.first]
    send(action) if action
  end

  private

  # redirect to the phoenix app submission attachment export
  def phoenix_submission_attachments_url
    "#{Rails.configuration.phx_interop[:phx_uri]}/challenges/#{@phase.challenge.id}/phases/#{@phase.id}"
  end

  def redirect_to_phoenix_submission_attachments
    {
      redirect_url: phoenix_submission_attachments_url,
      status: :see_other
    }
  end

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
      'Evaluation Status', 'Total Score'
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
