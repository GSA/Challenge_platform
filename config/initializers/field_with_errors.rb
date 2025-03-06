# frozen_string_literal: true

ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  if html_tag.include?('type="radio"') || html_tag.include?('data-skip-error-class="true"')
    html_tag.html_safe # Do not wrap radio buttons
  else
    # Wrap other inputs with the default div
    %(<div class="field_with_errors">#{html_tag}</div>).html_safe
  end
end
