module Matomo
  module ViewHelpers
    def matomo_tracking_url
      "#{Matomo.base_url}/js/?" + {
        idsite: Matomo.site_id,
        rec: 1,
        action_name: page_title,
        url: request.original_url
      }.to_param
    end

    def matomo_tracking_embed
      content_tag(:div, id: "anon-stats") do
        content_tag(:noscript) do
          tag(:img, src: matomo_tracking_url, style: "border:0", alt: "")
        end +
        javascript_tag do
          "document.getElementById('anon-stats').innerHTML = '<img src=\"#{matomo_tracking_url}\"?urlref=' + encodeURIComponent(document.referrer) + 'style=\"border:0\" alt=\"\" />';".html_safe
        end
      end
    end
  end
end
