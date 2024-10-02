class FormValidations::EvaluationFormsController < EvaluationFormsController
  def update
    @evaluation_form.assign_attributes(evaluation_form_params)
    @evaluation_form.valid?
    respond_to do |format|
      format.text do
        render partial: "evaluation_forms/form", locals: { evaluation_form: @evaluation_form }, formats: [:html]
      end
    end
  end
   
  def create
    @evaluation_form = evaluation_form.new(evaluation_form_params)
    @evaluation_form.validate
    respond_to do |format|
      format.text do
        render partial: "evaluation_forms/form", locals: { evaluation_form: @evaluation_form }, formats: [:html]
      end
    end
  end
end
