# frozen_string_literal: true

class ChallengesController < ApplicationController
  def show
    @challenge = Challenge.includes(phases: {phase_winner: :winners})
                          .find_by(custom_url: params[:challenge])
    @section = params[:section] || 'overview'

    if @challenge.nil?
      redirect_to '/', alert: "Challenge not found."
      return
    end

    @logo_url = determine_logo_url
    render :show
  end

  def contact
    return unless find_challenge

    result = ContactFormsService.send_email(@challenge, contact_form_params)

    if result[:success]
      flash[:notice] = "Your message has been sent successfully."
    else
      flash[:error] = result[:errors].join(", ")
    end

    redirect_to return_to_section_path, allow_other_host: false
  end

  private

  def determine_logo_url
    return nil unless @challenge.upload_logo
    return nil unless @challenge.logo_key.present?

    if Rails.env.production? || Rails.env.staging?
      s3_logo_url(@challenge)
    else
      file_system_logo_url(@challenge)
    end
  end

  def file_system_logo_url(challenge)
    "#{ENV.fetch('PHOENIX_URI')}/uploads/challenges/original-#{challenge.logo_key}#{challenge.logo_extension}"
  end

  def s3_logo_url(challenge)
    "#{ENV.fetch('S3_BASE_URL')}/challenges/original-#{challenge.logo_key}#{challenge.logo_extension}"
  end

  # contact form
  def find_challenge
    @challenge = Challenge.find_by(custom_url: params[:challenge]) ||
                 Challenge.find(params[:challenge])

    if @challenge.nil?
      flash[:error] = "Challenge not found"
      redirect_to challenges_path
      return false
    end

    true
  end

  def return_to_section_path
    if @challenge.status == "archived"
      archived_challenge_path(@challenge.custom_url || @challenge.id)
    else
      challenge_path(@challenge.custom_url || @challenge.id)
    end
  end

  def contact_form_params
    params.permit(:email, :body)
  end
end
