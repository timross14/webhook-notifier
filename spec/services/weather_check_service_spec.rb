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

    let(:url1) { 'http://weather-alerts.com/api?zip_code=10000' }
    let(:url2) { 'http://weather-alerts.com/api?zip_code=20000' }
    let(:url3) { 'http://weather-alerts.com/api?zip_code=30000' }

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
    let(:url) { 'http://weather-alerts.com/api?zip_code=10000' }
    subject do
      WeatherCheckService.make_get_request(url)
    end
    it 'calls the api' do
      subject
      expect(a_request(:get, url)).to have_been_made.once
    end

    it 'returns a faraday response' do
      expect(subject).to be_an_instance_of(Faraday::Response)
    end
  end

  describe 'check_responses' do
    context 'valid responses' do
      let!(:warning_webhook) { create(:warning_webhook) }
      let!(:watch_webhook) { create(:watch_webhook) }
      #need to mock the below as faraday response objects
      let(:response1) { OpenStruct.new(:body => "{\"zip_code\":\"10000\",\"status\":\"quiet\"}") }
      let(:response2) { OpenStruct.new(:body => "{\"zip_code\":\"20000\",\"status\":\"watch\"}") }
      let(:response3) { OpenStruct.new(:body => "{\"zip_code\":\"30000\",\"status\":\"warning\"}") }
      let(:responses) { [response1, response2, response3] }

      subject do
        WeatherCheckService.check_responses(responses)
      end

      it 'calls spawn_workers twice' do
        expect(WeatherCheckService).to receive(:spawn_worker).twice
        subject
      end
    end

    context 'invalid responses' do
      #need to test and handle more here
    end
  end
end
