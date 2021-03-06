require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe WebhookWorker, type: :worker do

  let(:zip) { '20000' }
  let(:name) { 'watch' }
  let(:response) { 'response_example' }
  let(:status) { '200' }
  let(:webhook_id) { 1 }
  let(:url) { 'http://example.com' }


  describe 'record_event' do
    subject do
      wh_worker = WebhookWorker.new
      wh_worker.record_event(response, status, webhook_id)
    end

    context 'there is no associated webhook' do
      it 'does not create an event if there is no associated webhook' do
        expect { subject }.to_not change { WebhookEvent.count }
      end
    end

    context 'there is a webhook' do
      let!(:webhook) { create(:warning_webhook) }
      it 'creates an event' do
        expect { subject }.to change { WebhookEvent.count }.from(0).to(1)
      end

      it 'creates webhook event with proper values' do
        subject
        event = WebhookEvent.first
        expect(event.webhook_id).to eq(webhook_id)
        expect(event.status).to eq(status)
        expect(event.response).to eq(response)
      end
    end

    context 'the webhook returns an error' do
      let!(:webhook) { create(:warning_webhook) }
      let(:response) { nil }
      let(:status) { '404' }

      it 'creates an event' do
        expect { subject }.to change { WebhookEvent.count }.from(0).to(1)
      end

      it 'creates webhook event with proper values' do
        subject
        event = WebhookEvent.first
        expect(event.webhook_id).to eq(webhook_id)
        expect(event.status).to eq(status)
        expect(event.response).to eq(response)
      end
    end
  end

  describe 'create_payload' do
    let(:valid_payload) { { name: name, zip: zip } }

    it 'creates a payload' do
      wh_worker = WebhookWorker.new
      allow(wh_worker).to receive(:create_payload).with(name, zip).and_return(valid_payload)
    end
  end

  describe 'make_webhook_request' do
    let(:webhook) { create(:warning_webhook) }
    let(:payload) { { name: name, zip: zip } }

    before do
      stub_webhook_warning(url)
    end

    subject do
      wh_worker = WebhookWorker.new
      wh_worker.make_webhook_request(webhook, payload)
    end

    it 'makes a post' do
      subject
      assert_requested :post, url, :body => payload
    end
  end

  describe 'perform' do
    let(:webhook) { create(:warning_webhook) }

    subject do
      WebhookWorker.perform_async(webhook)
    end

    it 'queues a job' do
      subject
      expect(WebhookWorker.jobs.size).to eq(1)
    end
  end
end
