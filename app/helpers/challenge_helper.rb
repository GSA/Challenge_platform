# frozen_string_literal: true

# ChallengeHelper is the helper for challenge show page in public facing pages.
module ChallengeHelper

  # submission period info for challenge
  def format_submission_period(challenge)
    phases = challenge.phases

    if single_phase?(challenge)
      {
        phase: phases.first,
        status_text: submission_status_text(phases.first),
        closing_soon: phase_closing_soon?(phases.first)
      }
    else
      current_phase = get_current_phase(phases)
      previous_phase = get_previous_phase(phases)
      next_phase = get_next_phase(phases)
      {
        status_text: multi_phase_status_text(challenge, current_phase, previous_phase, next_phase)
      }
    end
  end

  # challenge type(s)
  def types_text(challenge)
    if challenge.types.any?
      "#{challenge.primary_type}; #{challenge.types.join('; ')}"
    else
      challenge.primary_type
    end
  end

  def follow_button_text(challenge)
    if challenge.gov_delivery_subscribers > 0
      "Follow challenge (#{challenge.gov_delivery_subscribers})"
    else
      "Follow challenge"
    end
  end

  # challenge timeline
  def format_local_datetime(date)
    date.strftime("%B %d, %Y %I:%M %p")
  end

  # challenge prizes
  def show_monetary_prizes?(challenge)
    (challenge.prize_type == "monetary" || challenge.prize_type == "both") &&
    challenge.prize_total.to_i > 0
  end

  def show_non_monetary_prizes?(challenge)
    (challenge.prize_type == "non_monetary" || challenge.prize_type == "both") &&
    challenge.non_monetary_prizes.present?
  end

  def safe_how_to_enter_link(challenge)
    return nil unless challenge.how_to_enter_link.present?

    url = if challenge.how_to_enter_link.start_with?('http')
      challenge.how_to_enter_link
    else
      "https://#{challenge.how_to_enter_link}"
    end

    begin
      uri = URI.parse(url)
      raise URI::InvalidURIError unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      url
    rescue URI::InvalidURIError
      nil
    end
  end

  def has_phase_winner_data?(phase_winner)
    phase_winner.overview.present? ||
    phase_winner.overview_image_path.present? ||
    phase_winner.winners&.any?
  end

  # apply for this challenge / apply on external website
  def show_apply_button?(challenge)
    return true if challenge.external_url.present?
    return true if safe_how_to_enter_link(challenge).present?

    current_phase = get_current_phase(challenge.phases)
    next_phase = get_next_phase(challenge.phases)

    return false if !current_phase && !next_phase
    return true if current_phase&.open_to_submissions
    return true if !current_phase && next_phase

    false
  end

  def apply_button_url(challenge)
    if challenge.external_url.present?
      challenge.external_url
    elsif safe_how_to_enter_link(challenge).present?
      safe_how_to_enter_link(challenge)
    elsif current_phase&.open_to_submissions
      new_challenge_submission_path(challenge)
    end
  end

  def apply_button_text(challenge)
    if challenge.external_url.present?
      "View on external website"
    elsif safe_how_to_enter_link(challenge).present?
      "Apply on external website"
    else
      current_phase = get_current_phase(challenge.phases)
      next_phase = get_next_phase(challenge.phases)

      if !current_phase && next_phase
        "Apply starting #{format_date(next_phase.start_date)}"
      elsif current_phase&.open_to_submissions
        "Apply for this challenge"
      end
    end
  end

  private

  def phase_number(challenge, phase)
    return nil unless phase
    challenge.phases.to_a.index(phase) + 1
  end

  # submission period information for challenge
  def submission_status_text(phase)
    if phase_in_future?(phase)
      "Coming soon / Open on #{format_local_datetime(phase.start_date)}"
    elsif phase_is_current?(phase)
      "Open until #{format_local_datetime(phase.end_date)}"
    elsif phase_in_past?(phase)
      "Closed on #{format_local_datetime(phase.end_date)}"
    end
  end

  def multi_phase_status_text(challenge, current_phase, previous_phase, next_phase)
    if current_phase
      "Phase #{phase_number(challenge, current_phase)} open until #{format_local_datetime(current_phase.end_date)}"
    elsif !previous_phase && next_phase
      "Phase #{phase_number(challenge, next_phase)} opens on #{format_local_datetime(next_phase.start_date)}"
    elsif previous_phase && next_phase
      "Phase #{phase_number(challenge, previous_phase)} closed / Phase #{phase_number(challenge, next_phase)} opens on #{format_local_datetime(next_phase.start_date)}"
    elsif previous_phase && !next_phase
      "Closed to submissions"
    end
  end

  def single_phase?(challenge)
    challenge.phases.length == 1
  end

  def phase_in_future?(phase)
    phase.start_date > Time.current
  end

  def phase_is_current?(phase)
    current_time = Time.current
    phase.start_date <= current_time && phase.end_date > current_time
  end

  def phase_is_next?(phase)
    phase.start_date > Time.current
  end

  def phase_in_past?(phase)
    phase.end_date <= Time.current
  end

  def phase_closing_soon?(phase)
    return false unless phase_is_current?(phase)
    five_days_from_now = 5.days.from_now.utc
    phase.end_date <= five_days_from_now
  end

  def phase_status_text(phase)
    if phase_in_past?(phase)
      'closed'
    elsif phase_is_current?(phase)
      "open until #{format_local_date(phase.end_date)}"
    elsif phase_in_future?(phase)
      "opens on #{format_local_date(phase.start_date)}"
    end
  end

  def phase_status_class(phase)
    if phase_in_past?(phase)
      'phase__text phase__text--closed'
    elsif phase_is_current?(phase)
      'phase__text phase__text--open'
    elsif phase_in_future?(phase)
      'phase__text'
    end
  end

  def format_local_date(date)
    date.strftime("%m/%d/%y")
  end

  def format_date(date)
    date.strftime("%B %-d, %Y")
  end

  def get_current_phase(phases)
    current_time = Time.current
    phases.find { |phase| phase.start_date <= current_time && phase.end_date > current_time }
  end

  def get_previous_phase(phases)
    current_time = Time.current
    phases.reverse.find { |phase| phase.end_date <= current_time }
  end

  def get_next_phase(phases)
    current_time = Time.current
    phases.find { |phase| phase.start_date > current_time }
  end
end
