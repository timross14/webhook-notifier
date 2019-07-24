class WeatherCheckWorker
  include Sidekiq::Worker

  def perform(*args)
    WeatherCheckService.call
  end
end
