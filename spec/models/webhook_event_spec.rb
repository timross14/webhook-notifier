require 'rails_helper'

RSpec.describe WebhookEvent, type: :model do
  let(:webhook_event) { create(:webhook_event) }

  describe 'validations' do
    subject { webhook_event }
    it { is_expected.to validate_presence_of(:webhook_id) }
  end

  describe 'associations' do
    subject { webhook_event }
    it { should belong_to(:webhook) }
  end

end
