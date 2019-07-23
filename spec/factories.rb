FactoryBot.define do

  factory :warning_webhook, class: Webhook do
    name { 'warning' }
    url { 'http://example.com' }
    zip_code { '30000' }
  end

  factory :watch_webhook, class: Webhook do
    name { 'watch' }
    url { 'http://other-example.com' }
    zip_code { '20000' }
  end

  factory :webhook_event do
    webhook { create(:warning_webhook) }
    status { '200' }
    response { 'good response' }
  end
end