class WebhookWorker
  include Sidekiq::Worker

  def perform(webhook)
    return unless webhook&.valid?
    payload = create_payload(webhook.name, webhook.zip_code)
    response, status = make_webhook_request(webhook, payload)
    record_event(response, status, webhook.id)
  end

  def record_event(response, status, webhook_id)
    WebhookEvent.create(response: response, status: status, webhook_id: webhook_id)
  end

  def make_webhook_request(webhook, payload)
    resp = Faraday.post(webhook.url, payload)
    response = JSON.parse(resp.body) if resp.body
    [response, resp.status]
  end

  def create_payload(name, zip)
    { name: name, zip: zip }
  end
end