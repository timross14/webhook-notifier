require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe WeatherCheckService do
  include WebMocks
  before do
    stub_quiet_request
    stub_watch_request
    stub_warning_request
  end

  describe 'call' do
    let!(:warning_webhook) { create(:warning_webhook) }
    let!(:watch_webhook) { create(:watch_webhook) }

    subject do
      WeatherCheckService.call
    end

    let(:url1) { 'https://weather-alerts.com/api?zip_code=10000' }
    let(:url2) { 'https://weather-alerts.com/api?zip_code=20000' }
    let(:url3) { 'https://weather-alerts.com/api?zip_code=30000' }

    it 'makes calls for all zip codes' do
      subject
      expect(a_request(:get, url1)).to have_been_made.once
      expect(a_request(:get, url2)).to have_been_made.once
      expect(a_request(:get, url3)).to have_been_made.once
    end

    it 'schedules a webhook worker to execute each in a background job' do
      subject
      assert_equal 2, WebhookWorker.jobs.size
    end
  end

  describe 'make_get_request' do
    let(:url) { 'https://weather-alerts.com/api?zip_code=10000' }
    before do
      WeatherCheckService.make_get_request(url)
    end
    it 'calls the api' do
      expect(a_request(:get, url)).to have_been_made.once
    end
  end
end
