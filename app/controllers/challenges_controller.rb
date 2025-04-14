# frozen_string_literal: true

# Controller for challenge listings detail page and contact form handling
class ChallengesController < ApplicationController
  def show
    @challenge = Challenge.includes(phases: { phase_winner: :winners }).
      find_by(custom_url: params[:challenge])
    @section = params[:section] || 'overview'

    if @challenge.nil?
      redirect_to '/', alert: t('challenge_listing.alerts.error')
      return
    end

    set_archived_notice if @challenge.archived?
    @logo_url = helpers.challenge_logo_url(@challenge)
    render :show
  end

  def contact
    return unless find_challenge

    result = ContactFormsService.send_email(@challenge, contact_form_params)

    if result[:success]
      flash[:notice] = t('mailers.contact_form.sent_successfully')
    else
      flash[:error] = result[:errors].join(", ")
    end

    redirect_to return_to_section_path, allow_other_host: false
  end

  private

  # contact form
  def find_challenge
    @challenge = Challenge.find_by(custom_url: params[:challenge]) || Challenge.find(params[:challenge])

    if @challenge.nil?
      flash[:error] = t('challenge_listing.alerts.error')
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

  def set_archived_notice
    flash[:info] = t('challenge_listing.alerts.archived')
  end

  def contact_form_params
    params.permit(:email, :body)
  end
end
