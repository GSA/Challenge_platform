# frozen_string_literal: true

json.extract!(evaluation_form, :id, :title, :instructions, :phase_id, :status, :comments_required,
              :weighted_scoring, :publication_date, :closing_date, :challenge_id, :created_at, :updated_at)
json.url(evaluation_form_url(evaluation_form, format: :json))
