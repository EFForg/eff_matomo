module Matomo
  module ViewHelpers
    def matomo_tracking_embed(opts = {})
      content_tag(:div, id: "anon-stats") do
        content_tag(:noscript) do
          tag(:img, src: matomo_tracking_url(opts), style: "border:0", alt: "")
        end +
        javascript_tag do
          "document.getElementById('anon-stats').innerHTML = '<img src=\"#{matomo_tracking_url(opts)}\"?urlref=' + encodeURIComponent(document.referrer) + 'style=\"border:0\" alt=\"\" />';".html_safe
        end
      end
    end

    def matomo_tracking_url(opts = {})
      "#{Matomo.base_url}/js/?" + {
        idsite: Matomo.site_id,
        rec: 1,
        action_name: action_name_or_default(opts[:action_name]),
        url: request.original_url
      }.compact.to_param
    end

    private

    def action_name_or_default(name)
      return name unless name.nil?
      return page_title if defined?(page_title)
      return nil
    end
  end
end
