# frozen_string_literal: true

module NavigationHelper

    def utility_menu_link_desktop(image_path, href, alt, button_label)
        render :partial => "navigation/utility_menu_link_desktop", :locals => {image_path: image_path, href: href, alt: alt, button_label: button_label}
    end   
end
