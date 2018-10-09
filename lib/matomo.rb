require "matomo/version"
require 'matomo/railtie' if defined?(Rails)
require "active_support/core_ext/hash"
require "active_support/core_ext/string"
require "httparty"

module Matomo
  class Referrer
    attr_accessor :label, :visits

    def initialize(params)
      @label = params["label"]
      @visits = params["nb_visits"]
      @actions = params["nb_actions"]
    end

    def actions_per_visit
      return 0 unless @actions and @visits
      (@actions/@visits.to_f).round(1)
    end
  end

  class VisitedPage
    attr_accessor :label, :hits, :visits

    def initialize(parent_page, params)
      @parent_page = parent_page
      @label = params["label"].sub!(/^\//, "") if params["label"]
      @hits = params["nb_hits"]
      @visits = params["nb_visits"]
    end

    def path
      "/#{@parent_page}/#{@label}"
    end
  end

  def self.top_referrers(**args)
    params = { method: "Referrers.getAll" }.merge(
      date_range_params(args[:start_date], args[:end_date])
    )
    if args[:path]
      params[:segment] = "pageUrl==#{tracked_site_url}#{args[:path]}"
    end
    resp = get(params)
    return [] if resp.response.code != "200"
    resp.map{ |x| Referrer.new(x) }
  end

  def self.get_subtables
    # Get a mapping from resource paths to Matomo page view subtable ids
    resp = get({
      method: "Actions.getPageUrls",
      filter_limit: 50,
    })
    if resp.response.code == "200"
      @subtables = resp.map{|x| [x["label"], x["idsubdatatable"]]}.to_h
    else
      @subtables = {}
    end
  end

  def self.method_missing(name, *args)
    # Add top_#{resource} methods to display Matomo page view subtables
    super unless name.to_s.starts_with?("top_")
    get_subtables unless @subtables
    parent_page = name.to_s.sub("top_", "")
    return [] unless @subtables[parent_page]

    resp = get({
      method: "Actions.getPageUrls",
      idSubtable: @subtables[parent_page],
    })
    return [] if resp.response.code != "200"
    resp.map{ |x| VisitedPage.new(parent_page, x) }
  end

  def self.visits_graph_url
    base_url + "?" + default_api_params.merge({
      method: "ImageGraph.get",
      apiModule: "VisitsSummary",
      apiAction: "get",
      token_auth: "anonymous",
      width: 800,
      height: 400,
      period: "day",
    }).to_query
  end

  def self.top_pages_url
    base_portal_url+"&category=General_Actions&subcategory=General_Pages"
  end

  def self.top_referrers_url
    base_portal_url+"&category=Referrers_Referrers&subcategory=Referrers_WidgetGetAll"
  end

  private

  def self.get(params)
    url = base_url + "?" + default_api_params.merge(params).to_query
    HTTParty.get(url)
  end

  def self.base_url
    ENV["MATOMO_BASE_URL"] || "https://anon-stats.eff.org"
  end

  def self.site_id
    ENV["MATOMO_SITE_ID"]
  end

  # ##
  # Gnarly base url for finding pages on the Matomo web portal
  def self.base_portal_url
    "#{base_url}/index.php?module=CoreHome&action=index&"\
    "idSite=#{site_id}&period=#{default_api_params[:period]}&date=#{default_api_params[:date]}&updated=1#?"\
    "idSite=#{site_id}&period=#{default_api_params[:period]}&date=#{default_api_params[:date]}"\
  end

  def self.default_api_params
    {
      module: "API",
      idSite: site_id,
      format: "JSON",
      period: "range",
      date: "last30",
      filter_limit: 5
    }
  end

  def self.date_range_params(start_date, end_date)
    date_format = "%Y-%m-%d"
    end_date = end_date || Date.today
    start_date = start_date || end_date - 30.days
    {
      period: "range",
      date: start_date.strftime(date_format) + "," + end_date.strftime(date_format)
    }
  end

  ##
  # The full url of a tracked page is sometimes required by the API, eg. when
  # scoping by page.  We can load the base url from the environment or by
  # making an API call.
  def self.tracked_site_url
    return ENV["MATOMO_TRACKED_SITE_URL"] if ENV["MATOMO_TRACKED_SITE_URL"]
    return @tracked_site_url if @tracked_site_url
    resp = get({
      method: "SitesManager.getSiteUrlsFromId"
    })
    return nil if resp.response.code != "200" || resp.length == 0
    @tracked_site_url = resp[0]
  end
end
