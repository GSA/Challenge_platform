# frozen_string_literal: true

# ChallengeHelper is the helper for challenge show page in public facing pages.
module ChallengeHelper
  include SubmissionPeriodHelper

  # challenge type(s)
  def types_text(challenge)
    if challenge.types.any?
      "#{challenge.primary_type}; #{challenge.types.join('; ')}"
    else
      challenge.primary_type
    end
  end

  def follow_button_text(challenge)
    if challenge.gov_delivery_subscribers.positive?
      "Follow challenge (#{challenge.gov_delivery_subscribers})"
    else
      "Follow challenge"
    end
  end

  # challenge prizes
  def show_monetary_prizes?(challenge)
    (challenge.prize_type == "monetary" || challenge.prize_type == "both") &&
      challenge.prize_total.to_i.positive?
  end

  def show_non_monetary_prizes?(challenge)
    (challenge.prize_type == "non_monetary" || challenge.prize_type == "both") &&
      challenge.non_monetary_prizes.present?
  end

  def safe_how_to_enter_link(challenge)
    return nil if challenge.how_to_enter_link.blank?

    url = build_full_url(challenge.how_to_enter_link)
    validate_url(url)
  end

  def phase_winner_data?(phase_winner)
    phase_winner.overview.present? ||
      phase_winner.overview_image_path.present? ||
      phase_winner.winners&.any?
  end

  # apply for this challenge / apply on external website
  def show_apply_button?(challenge)
    return true if external_links_present?(challenge)
    phase_allows_apply?(challenge)
  end

  def apply_button_url(challenge)
    if challenge.external_url.present?
      challenge.external_url
    elsif safe_how_to_enter_link(challenge).present?
      safe_how_to_enter_link(challenge)
    else
      current_phase = get_current_phase(challenge.phases)
      if current_phase&.open_to_submissions
        phoenix_new_challenge_submission_url(challenge)
      end
    end
  end

  def apply_button_text(challenge)
    return external_url_text(challenge) if challenge.external_url.present?
    return t('challenge_listing.apply.apply_on_external_website') if safe_how_to_enter_link(challenge).present?

    phase_based_button_text(challenge)
  end

  private

  # Phoenix new challenge submission URL
  def phoenix_new_challenge_submission_url(challenge)
    "#{Rails.configuration.phx_interop[:phx_uri]}/challenges/#{challenge.id}/submissions/new"
  end

  # how to enter link
  def build_full_url(link)
    link.start_with?('http') ? link : "https://#{link}"
  end

  def validate_url(url)
    uri = URI.parse(url)
    return url if valid_http_uri?(uri)
    nil
  rescue URI::InvalidURIError
    nil
  end

  def valid_http_uri?(uri)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  end

  # Apply for challenge
  def external_url_text(_challenge)
    t('challenge_listing.apply.view_on_external_website')
  end

  def phase_based_button_text(challenge)
    current_phase = get_current_phase(challenge.phases)
    next_phase = get_next_phase(challenge.phases)

    if !current_phase && next_phase
      future_phase_text(next_phase)
    elsif current_phase&.open_to_submissions
      t('challenge_listing.apply.in_challenge_gov')
    end
  end

  def future_phase_text(next_phase)
    t('challenge_listing.apply.future_phase', date: format_date(next_phase.start_date))
  end

  def external_links_present?(challenge)
    challenge.external_url.present? || safe_how_to_enter_link(challenge).present?
  end

  def phase_allows_apply?(challenge)
    current_phase = get_current_phase(challenge.phases)
    next_phase = get_next_phase(challenge.phases)

    return false if no_valid_phases?(current_phase, next_phase)
    current_phase&.open_to_submissions || next_phase.present?
  end

  def no_valid_phases?(current_phase, next_phase)
    !current_phase && !next_phase
  end
end
