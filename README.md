# EFF Matomo

The EFF Matomo gem provides utilities for integrating our Ruby applications with our analytics tool, Matomo.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eff_matomo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eff_matomo

## Usage

### Configuration

This gem reads two environment variables:
* `MATOMO_SITE_ID`: The ID in Matomo of the app being tracked. **Required**.
* `MATOMO_BASE_URL`: The URL where Matomo is being hosted. Defaults to "https://anon-stats.eff.org".

### Adding the Matomo tracking embed to a Rails app

Add `<%= matomo_tracking_embed %>` to the footer of your application layout template.

### Displaying Matomo data

This gem provides allows users to import site usage data from Matomo to display in their application. It currently supports two types of data:

**Referrers** show how users are reaching the application. Usage example:
```ruby
# Get the top five referrers for the site
referrers = Matomo::Referrer.top

# Scope referrers by date range
referrers = Matomo::Referrer.where(start_date: Time.now - 1.month, end_date: Time.now)

# Only show referrers for a certain page within the app
referrers = Matomo::Referrer.where(path: "/action/my-important-action")

# Access information about each referrers
referrers.each() do |referrer|
  puts referrer.label             # eg. "facebook.com"
  puts referrer.visits            # Number of times a visit came from this referrer
  puts referrer.actions_per_visit # Average number of actions that occured during a visit
end
```

**Visited Pages** show the top pages within the application, both in terms of unique page views and overall number of hits. Usage example:
```ruby
# Get the top pages under a certain path, for example under "/articles"
pages = Matomo::VisitedPage.where(base_path: "/articles")

# Access information about each page
pages.each() do |page|
  puts page.label # eg. "/harm-reduction"
  puts page.path # eg. "/acticles/harm-reduction"
  puts page.hits # Overall number of hits on the page
  puts page.visits # The number of distinct visits to the page
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
