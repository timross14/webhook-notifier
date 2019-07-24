require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe WeatherCheckWorker, type: :worker do
  describe 'perform' do
    subject do
      WeatherCheckWorker.perform_async
    end

    it 'queues a job' do
      subject
      expect(WeatherCheckWorker.jobs.size).to eq(1)
    end
  end
end
