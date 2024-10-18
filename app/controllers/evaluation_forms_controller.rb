# frozen_string_literal: true

class EvaluationFormsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_evaluation_form, only: %i[show edit update destroy]
  before_action :set_evaluation_forms, only: %i[index]

  # GET /evaluation_forms or /evaluation_forms.json
  def index; end

  # GET /evaluation_forms/1 or /evaluation_forms/1.json
  def show; end

  # GET /evaluation_forms/new
  def new
    @evaluation_form = EvaluationForm.new
  end

  # GET /evaluation_forms/1/edit
  def edit; end

  # POST /evaluation_forms or /evaluation_forms.json
  def create
    @evaluation_form = EvaluationForm.new(evaluation_form_params)

    respond_to do |format|
      if @evaluation_form.save
        format.html do
          redirect_to evaluation_form_url(@evaluation_form), notice: I18n.t("evaluation_form_saved")
        end
        format.json { render :show, status: :created, location: @evaluation_form }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @evaluation_form.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /evaluation_forms/1 or /evaluation_forms/1.json
  def update
    respond_to do |format|
      if @evaluation_form.update(evaluation_form_params)
        format.html do
          redirect_to evaluation_form_url(@evaluation_form), notice: I18n.t("evaluation_form_saved")
        end
        format.json { render :show, status: :ok, location: @evaluation_form }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @evaluation_form.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /evaluation_forms/1 or /evaluation_forms/1.json
  def destroy
    @evaluation_form.destroy!

    respond_to do |format|
      format.html { redirect_to evaluation_forms_url, notice: I18n.t("evaluation_form_destroyed") }
      format.json { head(:no_content) }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_evaluation_form
    @evaluation_form = EvaluationForm.find(params[:id])
  end

  def set_evaluation_forms
    @evaluation_forms = EvaluationForm.by_user(current_user)
  end

  # Only allow a list of trusted parameters through.
  def evaluation_form_params
    params.require(:evaluation_form).permit(:title, :instructions, :challenge_phase, :status, :comments_required,
                                            :weighted_scoring, :publication_date, :closing_date, :challenge_id,
                                            evaluation_criteria_attributes: %i[
                                              id title description points_or_weight scoring_type
                                              option_range_start option_range_end option_labels _destroy
                                            ])
  end
end
