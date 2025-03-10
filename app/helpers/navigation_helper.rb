# frozen_string_literal: true

# View helpers for the top navigation bar and utility menu.
module NavigationHelper
  def utility_menu_link(image_path, href, _alt, button_label)
    link_to(href,
            class: "display-flex flex-align-center flex-row " \
                   "margin-x-3 text-white text-bold text-no-underline " \
                   "tablet:width-auto tablet:text-no-wrap text-center",
            id: "utility-menu-link-#{button_label}") do
      concat(
        image_tag(
          "images/usa-icons/#{image_path}.svg",
          class: "usa-icon--size-4 icon-white margin-right-1",
          alt: ""
        )
      )
      concat(
        tag.span(
          button_label,
          class: "text-white"
        )
      )
    end
  end
end
