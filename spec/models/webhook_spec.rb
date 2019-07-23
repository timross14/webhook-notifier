require 'rails_helper'

RSpec.describe Webhook, type: :model do
  let(:webhook) { create(:warning_webhook) }

  describe 'validations' do
    subject { webhook }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:zip_code) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:name).in_array(['watch', 'warning']) }
  end

  describe 'associations' do
    it { should have_many(:webhook_events) }
  end
end
