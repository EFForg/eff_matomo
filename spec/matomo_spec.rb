RSpec.describe Matomo do
  ENV["MATOMO_SITE_ID"] = "7"
  ENV["MATOMO_BASE_URL"] = "https://demo.matomo.org"

  it "has a version number" do
    expect(Matomo::VERSION).not_to be nil
  end

  describe "top pages" do
    subject do
      VCR.use_cassette("top_pages") do
        Matomo::VisitedPage.where(base_path: "/c")
      end
    end

    it "returns top articles as an array" do
      expect(subject.length).to eq(5)
    end

    it "exposes basic attributes about top articles" do
      expect(subject[0].label).to eq("support-bugs")
      expect(subject[0].visits).to eq(238)
      expect(subject[0].hits).to eq(373)
    end

    it "exposes the page path" do
      expect(subject[0].path).to eq("/c/support-bugs")
    end

    it "survives empty inputs" do
      Matomo::VisitedPage.new(nil, {})
    end

    describe "with access denied" do
      subject do
        VCR.use_cassette("top_pages_access_denied") do
          Matomo::VisitedPage.where(base_path: "/articles")
        end
      end

      it "returns an empty array" do
        expect(subject).to eq([])
      end
    end
  end

  describe "top referrers" do
    subject do
      VCR.use_cassette("top_referrers", :match_requests_on => [:method, :uri_without_date_param]) do
        Matomo::Referrer.top
      end
    end

    it "returns top referrers as an array" do
      expect(subject.length).to eq(5)
    end

    it "exposes basic attributes about referrers" do
      expect(subject[0].label).to eq("Keyword not defined")
      expect(subject[0].visits).to eq(16992)
    end

    it "computes actions per visit to one decimal" do
      expect(subject[0].actions_per_visit).to eq(1.7)
    end

    it "survives empty inputs" do
      visit = Matomo::Referrer.new({})
      expect(visit.actions_per_visit).to eq(0)
    end

    it "scopes referrers by path" do
      VCR.use_cassette("top_referrers_by_path", :match_requests_on => [:method, :uri_without_date_param]) do
        subject = Matomo::Referrer.where(path: "/latest")
        expect(subject[0].visits).to eq(14)
      end
    end

    it "accepts a date range" do
      VCR.use_cassette("top_referrers_by_date_range") do
        subject = Matomo::Referrer.where(start_date: Time.new(2018, 9, 9), end_date: Time.new(2018, 9, 25))
        expect(subject.length).to eq(5)
        expect(subject[0].visits).to eq(9080)
      end
    end

    describe "with access denied" do
      subject do
        VCR.use_cassette("top_referrers_access_denied", :match_requests_on => [:method, :uri_without_date_param]) do
          Matomo::Referrer.top
        end
      end

      it "returns an empty array" do
        expect(subject).to eq([])
      end
    end
  end

end
