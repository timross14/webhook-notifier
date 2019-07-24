require 'faraday'
require 'json'

ZIP_CODES = [10000, 20000, 30000]
BASE_URL = 'https://weather-alerts.com/api'

class WeatherCheckService
  def self.call
    responses = []
    ZIP_CODES.each do |zip|
      responses << make_get_request(BASE_URL + "?zip_code=#{zip.to_s}")
    end

    check_responses(responses)
  end

  def self.make_get_request(url)
    Faraday.get(url) do |req|
      req.headers['Content-Type'] = 'application/json' #faraday can implement parallelization (Typhoeus)
    end
  end

  def self.check_responses(responses)
    webhooks = Webhook.where("name = ? OR name = ?", 'watch', 'warning') #if we add relevant names in the future, we can add them here
    responses.each do |r|
      parsed_response = JSON.parse(r.body) if r.body
      status = parsed_response['status']
      zip = parsed_response['zip_code']
      webhooks.each do |webhook|
        if webhook.name == status && webhook.zip_code == zip
          spawn_worker(webhook)
        end
      end
    end
  end

  def self.spawn_worker(webhook)
    WebhookWorker.perform_async(webhook)
  end
end
