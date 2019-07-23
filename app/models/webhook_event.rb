class WebhookEvent < ApplicationRecord
  belongs_to :webhook

  validates_presence_of :webhook_id
end
