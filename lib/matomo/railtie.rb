require 'matomo/view_helpers.rb'
module Matomo
  class Railtie < Rails::Railtie
    ActionView::Base.send :include, Matomo::ViewHelpers
  end
end
