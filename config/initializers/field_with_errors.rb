ActionView::Base.field_error_proc = proc do |html_tag, instance|
  if html_tag =~ /type="radio"/
    html_tag.html_safe # Do not wrap radio buttons
  else
    # Wrap other inputs with the default div
    %(<div class="field_with_errors">#{html_tag}</div>).html_safe
  end
end