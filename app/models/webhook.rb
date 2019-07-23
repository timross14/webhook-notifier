class Webhook < ApplicationRecord
  has_many :webhook_events

  validates_presence_of :name
  validates_presence_of :url
  validates_presence_of :zip_code
  validates :name,

            :inclusion  => { :in => [ 'watch', 'warning'] }
end
