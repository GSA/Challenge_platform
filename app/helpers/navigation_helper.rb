# frozen_string_literal: true

module NavigationHelper
  def utility_menu_link(image_path, href, alt, button_label)
    link_to(href,
            class: "display-flex flex-align-center flex-column desktop:flex-row " \
                   "margin-x-1 desktop:margin-x-3 text-white text-no-wrap") do
      image_tag(
        "images/usa-icons/#{image_path}.svg",
        class: "usa-icon--size-4 desktop:usa-icon--size-3 icon-white desktop:margin-right-1",
        alt: ""
      ) +
        tag.span(button_label, class: "display-none desktop:display-block") +
        tag.span(button_label, class: "desktop:display-none", style: "font-size: 0.7rem")
    end
  end
end
