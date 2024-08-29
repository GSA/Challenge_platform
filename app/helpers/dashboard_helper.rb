# frozen_string_literal: true

module DashboardHelper
  
  def dashboard(user)
    cards = card_data[user.role.to_sym]

    render partial: "dashboard", locals: {cards: }
  end

  def dashboard_card(image_path, href, alt, title, subtitle)
    link_to(href,
            class: "display-flex flex-align-center flex-column desktop:flex-row " \
                   "margin-x-1 desktop:margin-x-3 text-white text-no-wrap") do
      image_tag(
        "images/usa-icons/#{image_path}.svg",
        class: "usa-icon--size-4 desktop:usa-icon--size-3 icon-white desktop:margin-right-1",
        alt:
      ) +
        tag.span(title, class: "") +
        tag.span(subtitle, class: "", style: "font-size: 0.7rem")
    end
  end

  def card_data
    {
      "challenge_manager": [
        {image_path: 'content_copy', href: 'evaluation_forms', alt: 'evaluation forms', title: 'Evaluation Forms', subtitle: 'Create and manage evaluation forms.'},
        {image_path: 'folder_open', href: 'manage_submissions', alt: 'submissions', title: 'Submissions', subtitle: 'Manage submissions, evaluations, and evaluators.'},
        {image_path: 'map', href: 'user_guide', alt: 'user guides', title: 'User Guides', subtitle: 'Learn how to make the most of the platform.'},
        {image_path: 'support_agent', href: 'federal-agency-faqs', alt: 'help', title: 'Help', subtitle: 'Get support on the Chalenge.Gov platform.'}

      ]
    }
  end
end